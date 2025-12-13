import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppUser {
  final String uid;
  final String? email;
  final Map<String, dynamic> data;

  AppUser({required this.uid, this.email, required this.data});
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _firebaseUser;
  AppUser? _user;
  List<Map<String, dynamic>> _addresses = [];
  String? _selectedAddressId;
  List<Map<String, dynamic>> _purchases = [];

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot>? _addressesSub;
  StreamSubscription<QuerySnapshot>? _purchasesSub;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authSub = _auth.authStateChanges().listen((u) async {
      _firebaseUser = u;
      if (u != null) {
        await _loadUserDoc(u.uid);
        _listenAddresses(u.uid);
        _listenPurchases(u.uid);
      } else {
        _user = null;
        _addresses = [];
        _selectedAddressId = null;
        _purchases = [];
        _addressesSub?.cancel();
        _purchasesSub?.cancel();
      }
      notifyListeners();
    });
  }

  bool get isLoggedIn => _firebaseUser != null;
  User? get firebaseUser => _firebaseUser;
  AppUser? get user => _user;
  List<Map<String, dynamic>> get addresses => List.unmodifiable(_addresses);
  String? get selectedAddressId => _selectedAddressId;
  Map<String, dynamic>? get selectedAddress => _addresses.firstWhere(
    (a) => a['id'] == _selectedAddressId,
    orElse: () => {},
  );

  List<Map<String, dynamic>> get purchases => List.unmodifiable(_purchases);

  Future<void> _loadUserDoc(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final raw = doc.exists
        ? doc.data() ?? <String, dynamic>{}
        : <String, dynamic>{};
    final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
    _user = AppUser(uid: uid, email: data['email'] as String?, data: data);
  }

  void _listenAddresses(String uid) {
    _addressesSub?.cancel();
    _addressesSub = _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .orderBy('createdAt')
        .snapshots()
        .listen((snap) {
          _addresses = snap.docs
              .map((d) => {'id': d.id, 'address': d['address']})
              .toList();
          // keep selectedAddressId if still present
          if (_selectedAddressId != null &&
              !_addresses.any((a) => a['id'] == _selectedAddressId)) {
            _selectedAddressId = null;
          }
          notifyListeners();
        });
  }

  void _listenPurchases(String uid) {
    _purchasesSub?.cancel();
    _purchasesSub = _db
        .collection('users')
        .doc(uid)
        .collection('purchases')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((snap) {
          _purchases = snap.docs.map((d) {
            final data = d.data();
            return {'id': d.id, ...data};
          }).toList();
          notifyListeners();
        });
  }

  Future<void> signIn(
    String email,
    String password, {
    bool remember = true,
  }) async {
    if (kIsWeb) {
      try {
        await _auth.setPersistence(
          remember ? Persistence.LOCAL : Persistence.SESSION,
        );
      } catch (_) {
        // Ignore persistence errors on Web
      }
    }
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _loadUserDoc(cred.user!.uid);
  }

  Future<void> createAccount(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    await _db.collection('users').doc(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _loadUserDoc(uid);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> addAddress(String address) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) throw StateError('Not logged in');

    try {
      await _db.collection('users').doc(uid).collection('addresses').add({
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateAddress(String id, String address) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) throw StateError('Not logged in');
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .doc(id)
          .update({'address': address});
    } catch (_) {
      rethrow;
    }
  }

  Future<void> removeAddress(String id) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) throw StateError('Not logged in');
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .doc(id)
          .delete();
      if (_selectedAddressId == id) {
        _selectedAddressId = null;
      }
    } catch (_) {
      rethrow;
    }
  }

  void selectAddress(String id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  Future<void> savePurchase(Map<String, dynamic> purchase) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) throw StateError('Not logged in');
    final ref = _db.collection('users').doc(uid).collection('purchases');
    await ref.add({...purchase, 'dateTime': FieldValue.serverTimestamp()});
  }

  Future<void> removePurchase(String id) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) throw StateError('Not logged in');
    await _db
        .collection('users')
        .doc(uid)
        .collection('purchases')
        .doc(id)
        .delete();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _addressesSub?.cancel();
    _purchasesSub?.cancel();
    super.dispose();
  }
}
