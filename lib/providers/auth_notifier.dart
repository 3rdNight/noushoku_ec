import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'auth_notifier.g.dart';

class AppUser {
  final String uid;
  final String? email;
  final Map<String, dynamic> data;

  AppUser({required this.uid, this.email, required this.data});
}

class AuthState {
  final User? firebaseUser;
  final AppUser? user;
  final List<Map<String, dynamic>> addresses;
  final String? selectedAddressId;
  final List<Map<String, dynamic>> purchases;
  final bool isLoading;
  final String? error;

  AuthState({
    this.firebaseUser,
    this.user,
    this.addresses = const [],
    this.selectedAddressId,
    this.purchases = const [],
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? firebaseUser,
    AppUser? user,
    List<Map<String, dynamic>>? addresses,
    String? selectedAddressId,
    List<Map<String, dynamic>>? purchases,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      user: user ?? this.user,
      addresses: addresses ?? this.addresses,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      purchases: purchases ?? this.purchases,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isLoggedIn => firebaseUser != null;

  Map<String, dynamic>? get selectedAddress => addresses.firstWhere(
    (a) => a['id'] == selectedAddressId,
    orElse: () => {},
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthNotifier() : super(AuthState()) {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((u) async {
      state = state.copyWith(firebaseUser: u);

      if (u != null) {
        await _loadUserDoc(u.uid);
        _listenPurchases(u.uid);
      } else {
        state = state.copyWith(
          user: null,
          addresses: [],
          selectedAddressId: null,
          purchases: [],
        );
      }
    });
  }

  Future<void> _loadUserDoc(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final raw = doc.exists
          ? doc.data() ?? <String, dynamic>{}
          : <String, dynamic>{};
      final Map<String, dynamic> data = Map<String, dynamic>.from(raw);

      // Fallback: get email from FirebaseAuth if not in Firestore
      final emailFromDoc = data['email'] as String?;
      final emailFromAuth = _auth.currentUser?.email;
      final finalEmail = emailFromDoc ?? emailFromAuth;

      // If email was missing in Firestore but we have it from Auth, save it
      if (emailFromDoc == null && emailFromAuth != null) {
        await _db.collection('users').doc(uid).set({
          'email': emailFromAuth,
        }, SetOptions(merge: true));
        data['email'] = emailFromAuth;
      }

      // Load addresses from array field
      final addressesRaw = data['addresses'] as List<dynamic>? ?? [];
      final List<Map<String, dynamic>> addresses = addressesRaw
          .asMap()
          .entries
          .map(
            (entry) => {
              'id': entry.key.toString(),
              ...Map<String, dynamic>.from(entry.value as Map),
            },
          )
          .toList();

      // Load selectedAddressId if stored
      final selectedAddressId = data['selectedAddressId'] as String?;

      final appUser = AppUser(uid: uid, email: finalEmail, data: data);
      state = state.copyWith(
        user: appUser,
        addresses: addresses,
        selectedAddressId: selectedAddressId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _listenPurchases(String uid) {
    _db
        .collection('users')
        .doc(uid)
        .collection('purchases')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen(
          (snap) {
            final purchases = snap.docs.map((d) {
              final data = d.data();
              return {'id': d.id, ...data};
            }).toList();
            state = state.copyWith(purchases: purchases);
          },
          onError: (e) {
            state = state.copyWith(error: e.toString());
          },
        );
  }

  Future<void> signIn(
    String email,
    String password, {
    bool remember = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (kIsWeb) {
        try {
          await _auth.setPersistence(
            remember ? Persistence.LOCAL : Persistence.SESSION,
          );
        } catch (e) {
          // Ignore persistence errors on Web
        }
      }
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      // Ensure user document exists with email
      await _db.collection('users').doc(uid).set({
        'email': email,
      }, SetOptions(merge: true));

      await _loadUserDoc(uid);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> createAccount(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      // Ensure user document exists with email
      try {
        await _db.collection('users').doc(uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (firestoreErr) {
        // Silently continue if write fails
      }

      await _loadUserDoc(uid);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      state = AuthState(); // reset to initial state
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> addAddress(String address) async {
    final uid = state.firebaseUser?.uid;
    if (uid == null) throw StateError('Not logged in');

    try {
      final addressObj = {
        'address': address,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };

      try {
        await _db.collection('users').doc(uid).set({
          'addresses': FieldValue.arrayUnion([addressObj]),
        }, SetOptions(merge: true));
      } catch (firestoreErr) {
        rethrow;
      }

      await _loadUserDoc(uid);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateAddress(String id, String address) async {
    final uid = state.firebaseUser?.uid;
    if (uid == null) throw StateError('Not logged in');

    try {
      // Get current addresses array
      final doc = await _db.collection('users').doc(uid).get();
      final addressesRaw = (doc.data()?['addresses'] as List<dynamic>?) ?? [];

      // Convert index id to int
      final idx = int.tryParse(id);
      if (idx == null || idx < 0 || idx >= addressesRaw.length) {
        throw StateError('Invalid address index: $id');
      }

      // Get old address to preserve createdAt
      final oldAddress = Map<String, dynamic>.from(addressesRaw[idx] as Map);
      final oldCreatedAt = oldAddress['createdAt'] as String?;

      // Create updated address object with preserved createdAt
      final newAddress = {
        'address': address,
        'createdAt': oldCreatedAt ?? DateTime.now().toUtc().toIso8601String(),
      };

      // Create new list with updated address at index
      final updatedAddresses = List<dynamic>.from(addressesRaw);
      updatedAddresses[idx] = newAddress;

      // Update array in Firestore
      await _db.collection('users').doc(uid).set({
        'addresses': updatedAddresses,
      }, SetOptions(merge: true));

      await _loadUserDoc(uid);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> removeAddress(String id) async {
    final uid = state.firebaseUser?.uid;
    if (uid == null) throw StateError('Not logged in');

    try {
      // Convert index id to int
      final idx = int.tryParse(id);
      if (idx == null || idx < 0) {
        throw StateError('Invalid address index: $id');
      }

      // Get current addresses array
      final doc = await _db.collection('users').doc(uid).get();
      final addressesRaw = (doc.data()?['addresses'] as List<dynamic>?) ?? [];

      if (idx >= addressesRaw.length) {
        throw StateError('Address index out of bounds: $idx');
      }

      // Create list without the removed address
      final updatedAddresses = List<dynamic>.from(addressesRaw);
      updatedAddresses.removeAt(idx);

      // Update Firestore
      await _db.collection('users').doc(uid).set({
        'addresses': updatedAddresses,
      }, SetOptions(merge: true));

      // Clear selectedAddressId if it was the removed one
      if (state.selectedAddressId == id) {
        state = state.copyWith(selectedAddressId: null);
      }

      await _loadUserDoc(uid);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void selectAddress(String id) {
    state = state.copyWith(selectedAddressId: id);
  }

  Future<void> savePurchase(Map<String, dynamic> purchase) async {
    final uid = state.firebaseUser?.uid;
    if (uid == null) throw StateError('Not logged in');
    try {
      final ref = _db.collection('users').doc(uid).collection('purchases');
      await ref.add({...purchase, 'dateTime': FieldValue.serverTimestamp()});
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> removePurchase(String id) async {
    final uid = state.firebaseUser?.uid;
    if (uid == null) throw StateError('Not logged in');
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('purchases')
          .doc(id)
          .delete();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier();
});

@riverpod
AuthState authState(Ref ref) {
  return ref.watch(authNotifierProvider);
}
