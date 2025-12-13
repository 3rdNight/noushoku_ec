import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_notifier.dart';

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
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _addressController?.dispose();
    super.dispose();
  }

  Future<void> _signIn(WidgetRef ref) async {
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showMsg("メールアドレスとパスワードを入力してください");
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final notifier = ref.read(authNotifierProvider.notifier);
      await notifier.signIn(email, pass, remember: _rememberMe);
      _showMsg("ログインしました");
    } catch (e) {
      _showMsg("ログイン中にエラーが発生しました: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _createAccount(WidgetRef ref) async {
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showMsg("メールアドレスとパスワードを入力してください");
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final notifier = ref.read(authNotifierProvider.notifier);
      await notifier.createAccount(email, pass);
      _showMsg("アカウントを作成しました");
    } catch (e) {
      _showMsg("登録エラーが発生しました: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _logout(WidgetRef ref) async {
    try {
      final notifier = ref.read(authNotifierProvider.notifier);
      await notifier.signOut();
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

  Future<void> _saveAddress(WidgetRef ref) async {
    if (_addressController == null) return;

    final value = _addressController!.text.trim();
    if (value.isEmpty) return;
    try {
      final state = ref.read(authNotifierProvider);
      if (!state.isLoggedIn) {
        _showMsg("ログインしてください");
        return;
      }

      final notifier = ref.read(authNotifierProvider.notifier);
      if (editingAddressId == null) {
        await notifier.addAddress(value);
      } else {
        await notifier.updateAddress(editingAddressId!, value);
      }
    } catch (e) {
      _showMsg('住所の保存中にエラーが発生しました: $e');
      return;
    }

    _closeAddressForm();
    _showMsg("保存されました");
  }

  Future<void> _removeAddress(String id, WidgetRef ref) async {
    try {
      final state = ref.read(authNotifierProvider);
      if (!state.isLoggedIn) {
        _showMsg("ログインしてください");
        return;
      }
      final notifier = ref.read(authNotifierProvider.notifier);
      await notifier.removeAddress(id);
      _showMsg("削除しました");
    } catch (e) {
      _showMsg('住所の削除中にエラーが発生しました');
    }
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
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text("マイページ", style: TextStyle(color: textColor)),
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final auth = ref.watch(authNotifierProvider);
          final isLogged = auth.isLoggedIn;
          return isLogged ? _buildLoggedInUI(ref) : _buildLoggedOutUI(ref);
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildLoggedOutUI(WidgetRef ref) {
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
                      onPressed: _isProcessing ? null : () => _signIn(ref),
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
                      onPressed: _isProcessing
                          ? null
                          : () => _createAccount(ref),
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

  Widget _buildLoggedInUI(WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
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
                        auth.user?.email ?? "(メールアドレスが設定されていません)",
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
                      if (auth.addresses.isEmpty && !showAddressForm)
                        const Text(
                          "住所は登録されていません",
                          style: TextStyle(color: textColor),
                        ),
                      ...auth.addresses.map((addr) {
                        final id = addr['id'] as String? ?? '';
                        final addressText = addr['address'] as String? ?? '';
                        return RadioListTile<String>(
                          value: id,
                          groupValue: auth.selectedAddressId,
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(authNotifierProvider.notifier)
                                  .selectAddress(val);
                            }
                          },
                          title: Text(
                            addressText,
                            style: const TextStyle(color: textColor),
                          ),
                          secondary: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: green),
                                onPressed: () =>
                                    _openAddressForm(addressText, id),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeAddress(id, ref),
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
                                onPressed: () => _saveAddress(ref),
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
                    onPressed: () => _logout(ref),
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
