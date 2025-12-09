import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'order_screen_history.dart';
import 'purchase_history_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // Colors
  static const Color green = Color(0xFF307A59);
  static const Color scaffoldBg = Color(0xFFE5E9EC);
  static const Color textColor = Color(0xFF1A4D2E);

  int _selectedBottomIndex = 3;

  // Controllers
  final TextEditingController _loginEmailCtrl = TextEditingController();
  final TextEditingController _loginPassCtrl = TextEditingController();
  TextEditingController? _addressController;

  // State
  bool _isProcessing = false;
  bool showAddressForm = false;
  bool _rememberMe = true; // default true for persistent login in browser

  User? _user;
  List<Map<String, dynamic>> addresses = [];

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot>? _addressSub;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initAuthPersistenceAndListener();
  }

  Future<void> _initAuthPersistenceAndListener() async {
    // For web: set default persistence to LOCAL so closing/reloading the browser keeps the session.
    // We still allow toggling via the "remember me" checkbox at sign-in.
    try {
      if (kIsWeb) {
        // Try to set LOCAL persistence at start; this makes the auth state persistent across tabs/reloads.
        await _auth.setPersistence(Persistence.LOCAL);
      }
    } catch (e) {
      // setPersistence is web-only; ignore errors for non-web platforms.
      // Keep silent (but could log to console for debugging).
    }

    // Listen to auth state changes
    _authSub = _auth.authStateChanges().listen((user) {
      _user = user;

      if (_user != null) {
        // Prefill email for convenience (and for browser autofill consistency)
        _loginEmailCtrl.text = _user!.email ?? '';

        // start listening to addresses in Firestore
        _listenAddresses(_user!.uid);
      } else {
        _loginEmailCtrl.clear();
        _loginPassCtrl.clear();
        addresses = [];
        _addressSub?.cancel();
      }

      if (mounted) setState(() {});
    });
  }

  void _listenAddresses(String uid) {
    _addressSub?.cancel();

    _addressSub = _db
        .collection("users")
        .doc(uid)
        .collection("addresses")
        .orderBy("createdAt")
        .snapshots()
        .listen((snapshot) {
          addresses = snapshot.docs
              .map((d) => {"id": d.id, "address": d["address"]})
              .toList();
          if (mounted) setState(() {});
        });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _addressSub?.cancel();

    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _addressController?.dispose();

    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showMsg("メールアドレスとパスワードを入力してください");
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // For web, set persistence based on _rememberMe.
      // Persistence.LOCAL -> persistent across browser restarts.
      // Persistence.SESSION -> cleared when tab/window is closed.
      if (kIsWeb) {
        try {
          await _auth.setPersistence(
            _rememberMe ? Persistence.LOCAL : Persistence.SESSION,
          );
        } catch (e) {
          // ignore if not supported
        }
      }

      await _auth.signInWithEmailAndPassword(email: email, password: pass);

      // After sign-in, Firebase will manage tokens and refresh automatically.
      _showMsg("ログインしました");
    } on FirebaseAuthException catch (e) {
      _showMsg("ログインエラー: ${e.message}");
    } catch (e) {
      _showMsg("ログイン中にエラーが発生しました");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _createAccount() async {
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showMsg("メールアドレスとパスワードを入力してください");
      return;
    }

    setState(() => _isProcessing = true);

    try {
      if (kIsWeb) {
        try {
          // keep same persistence as signIn (default LOCAL)
          await _auth.setPersistence(
            _rememberMe ? Persistence.LOCAL : Persistence.SESSION,
          );
        } catch (e) {}
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final uid = cred.user!.uid;

      await _db.collection("users").doc(uid).set({
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      _showMsg("アカウントを作成しました");
    } on FirebaseAuthException catch (e) {
      _showMsg("登録エラー: ${e.message}");
    } catch (e) {
      _showMsg("登録エラーが発生しました");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      _showMsg("ログアウトしました");
    } catch (e) {
      _showMsg("ログアウトエラー: ${e.toString()}");
    }
  }

  void _openAddressForm([String? text, String? id]) {
    _addressController = TextEditingController(text: text ?? "");
    editingAddressId = id;
    showAddressForm = true;
    setState(() {});
  }

  String? editingAddressId;

  void _closeAddressForm() {
    _addressController?.dispose();
    _addressController = null;
    editingAddressId = null;
    showAddressForm = false;
    setState(() {});
  }

  Future<void> _saveAddress() async {
    if (_addressController == null) return;

    final value = _addressController!.text.trim();
    if (value.isEmpty) return;

    if (_user == null) {
      _showMsg("ログインしてください");
      return;
    }

    final ref = _db.collection("users").doc(_user!.uid).collection("addresses");

    if (editingAddressId == null) {
      await ref.add({
        "address": value,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } else {
      await ref.doc(editingAddressId).update({"address": value});
    }

    _closeAddressForm();
    _showMsg("保存されました");
  }

  Future<void> _removeAddress(String id) async {
    if (_user == null) {
      _showMsg("ログインしてください");
      return;
    }

    await _db
        .collection("users")
        .doc(_user!.uid)
        .collection("addresses")
        .doc(id)
        .delete();

    _showMsg("削除しました");
  }

  void _showMsg(String txt) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt)));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: green),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: green, width: 2),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: green),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLogged = _user != null;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text("マイページ", style: TextStyle(color: textColor)),
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: isLogged ? _buildLoggedInUI() : _buildLoggedOutUI(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildLoggedOutUI() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: scaffoldBg,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "ログイン / 新規登録",
                style: TextStyle(fontWeight: FontWeight.bold, color: green),
              ),
              const SizedBox(height: 8),

              // AutofillGroup + proper autofillHints for browser password managers
              AutofillGroup(
                child: Column(
                  children: [
                    TextField(
                      controller: _loginEmailCtrl,
                      decoration: _inputDecoration("メールアドレス"),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _loginPassCtrl,
                      obscureText: true,
                      decoration: _inputDecoration("パスワード"),
                      autofillHints: const [AutofillHints.password],
                      onEditingComplete: () => FocusScope.of(context).unfocus(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Remember me (controls web persistence)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("ログイン状態を保持する"),
                value: _rememberMe,
                activeColor: green,
                onChanged: (v) {
                  setState(() {
                    _rememberMe = v ?? true;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("ログイン"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : _createAccount,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: green),
                        foregroundColor: green,
                      ),
                      child: const Text("新規作成"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedInUI() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
              ),
              child: const Text("個人情報"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PurchaseHistoryScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: green.withOpacity(0.7),
                foregroundColor: Colors.white,
              ),
              child: const Text("購入履歴"),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Card(
                color: scaffoldBg,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "メールアドレス",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _user?.email ?? "",
                        style: const TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Card(
                color: scaffoldBg,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "配送先住所",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (addresses.isEmpty && !showAddressForm)
                        const Text(
                          "住所は登録されていません",
                          style: TextStyle(color: textColor),
                        ),

                      ...addresses.map((addr) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            addr["address"],
                            style: const TextStyle(color: textColor),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: green),
                                onPressed: () => _openAddressForm(
                                  addr["address"],
                                  addr["id"],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeAddress(addr["id"]),
                              ),
                            ],
                          ),
                        );
                      }),

                      TextButton(
                        onPressed: () {
                          if (showAddressForm) {
                            _closeAddressForm();
                          } else {
                            _openAddressForm();
                          }
                        },
                        child: Text(
                          showAddressForm ? "キャンセル" : "＋新しく登録",
                          style: const TextStyle(
                            color: green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (showAddressForm)
                        Column(
                          children: [
                            TextField(
                              controller: _addressController,
                              maxLines: 2,
                              decoration: _inputDecoration("住所を入力"),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveAddress,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: green,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  editingAddressId == null ? "保存" : "更新",
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("ログアウト"),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  void _onBottomNavTap(int index) {
    if (_selectedBottomIndex == index) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const OrdersScreen();
        break;
      case 2:
        screen = const OrderHistoryScreen();
        break;
      default:
        screen = const MyPageScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }
}
