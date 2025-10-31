import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<String> emails = [];
  List<Map<String, String>> creditCards = [];
  List<String> addresses = [];

  bool showEmailForm = false;
  bool showCardForm = false;
  bool showAddressForm = false;

  int? editingEmailIndex;
  int? editingCardIndex;
  int? editingAddressIndex;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  static const Color green = Color(0xFF307A59);
  static const Color scaffoldBg = Color(0xFFE5E9EC);
  int _selectedBottomIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emails = prefs.getStringList('emails') ?? [];
      addresses = prefs.getStringList('addresses') ?? [];
      final cardList = prefs.getStringList('creditCards') ?? [];
      creditCards = cardList
          .map((e) => Map<String, String>.from(jsonDecode(e)))
          .toList();
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('emails', emails);
    await prefs.setStringList('addresses', addresses);
    await prefs.setStringList(
      'creditCards',
      creditCards.map((c) => jsonEncode(c)).toList(),
    );
  }

  void _onBottomNavTap(int index) {
    if (_selectedBottomIndex == index) return;
    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = const HomeScreen();
        break;
      case 1:
        targetScreen = const OrdersScreen();
        break;
      case 2:
        targetScreen = const OrderHistoryScreen();
        break;
      case 3:
        targetScreen = const MyPageScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
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
      border: const OutlineInputBorder(borderSide: BorderSide(color: green)),
    );
  }

  // ---- Email ----
  void _addOrEditEmail() {
    if (_emailController.text.isEmpty) return;
    setState(() {
      if (editingEmailIndex != null) {
        emails[editingEmailIndex!] = _emailController.text;
        editingEmailIndex = null;
      } else {
        emails.add(_emailController.text);
      }
      _emailController.clear();
      showEmailForm = false;
      _savePrefs();
    });
  }

  void _editEmail(int index) {
    setState(() {
      _emailController.text = emails[index];
      editingEmailIndex = index;
      showEmailForm = true;
    });
  }

  void _removeEmail(int index) {
    setState(() {
      emails.removeAt(index);
      _savePrefs();
    });
  }

  // ---- Address ----
  void _addOrEditAddress() {
    if (_addressController.text.isEmpty) return;
    setState(() {
      if (editingAddressIndex != null) {
        addresses[editingAddressIndex!] = _addressController.text;
        editingAddressIndex = null;
      } else {
        addresses.add(_addressController.text);
      }
      _addressController.clear();
      showAddressForm = false;
      _savePrefs();
    });
  }

  void _editAddress(int index) {
    setState(() {
      _addressController.text = addresses[index];
      editingAddressIndex = index;
      showAddressForm = true;
    });
  }

  void _removeAddress(int index) {
    setState(() {
      addresses.removeAt(index);
      _savePrefs();
    });
  }

  // ---- Credit Card ----
  void _addOrEditCard() {
    if (_cardNameController.text.isEmpty ||
        _cardNumberController.text.isEmpty ||
        _cardExpiryController.text.isEmpty ||
        _cardPhoneController.text.isEmpty)
      return;

    String expiryText = _cardExpiryController.text;
    if (!expiryText.contains('/')) {
      expiryText = expiryText.length >= 2
          ? '${expiryText.substring(0, 2)}/${expiryText.substring(2)}'
          : expiryText;
    }

    setState(() {
      final newCard = {
        'name': _cardNameController.text,
        'number': _cardNumberController.text,
        'expiry': expiryText,
        'phone': _cardPhoneController.text,
      };

      if (editingCardIndex != null) {
        creditCards[editingCardIndex!] = newCard;
        editingCardIndex = null;
      } else {
        creditCards.add(newCard);
      }

      _cardNameController.clear();
      _cardNumberController.clear();
      _cardExpiryController.clear();
      _cardPhoneController.clear();
      showCardForm = false;
      _savePrefs();
    });
  }

  void _editCard(int index) {
    final card = creditCards[index];
    setState(() {
      _cardNameController.text = card['name'] ?? '';
      _cardNumberController.text = card['number'] ?? '';
      _cardExpiryController.text = card['expiry'] ?? '';
      _cardPhoneController.text = card['phone'] ?? '';
      editingCardIndex = index;
      showCardForm = true;
    });
  }

  void _removeCard(int index) {
    setState(() {
      creditCards.removeAt(index);
      _savePrefs();
    });
  }

  Widget _buildSection({
    required String title,
    required List items,
    required VoidCallback onAdd,
    required bool showForm,
    required Widget formWidget,
    required String emptyText,
    required String addText,
    required void Function(int) onRemove,
    required void Function(int) onEdit,
  }) {
    return Card(
      color: scaffoldBg,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A4D2E),
              ),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty && !showForm)
              Text(emptyText, style: const TextStyle(color: Color(0xFF1A4D2E))),
            ...items.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              String display;
              if (item is Map<String, String>) {
                display =
                    '名義人: ${item['name']}\nカード番号: **** **** **** ${item['number']!.substring(item['number']!.length - 4)}\n有効期限: ${item['expiry']}\n電話番号: ${item['phone']}';
              } else {
                display = item.toString();
              }
              return ListTile(
                title: Text(
                  display,
                  style: const TextStyle(color: Color(0xFF1A4D2E)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => onEdit(idx),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onRemove(idx),
                    ),
                  ],
                ),
              );
            }),
            TextButton(
              onPressed: onAdd,
              child: Text(
                addText,
                style: const TextStyle(
                  color: green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (showForm) formWidget,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text('マイページ', style: TextStyle(color: Color(0xFF1A4D2E))),
        backgroundColor: scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A4D2E)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // BOTÕES DE NAVEGAÇÃO ACIMA DAS SEÇÕES
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: null, // já estamos na página de dados do cliente
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('個人情報'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PurchaseHistoryScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('購入履歴'),
                ),
              ],
            ),
          ),

          // EMAILS
          _buildSection(
            title: 'メールアドレス',
            items: emails,
            onAdd: () => setState(() => showEmailForm = !showEmailForm),
            showForm: showEmailForm,
            formWidget: Column(
              children: [
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: green),
                  cursorColor: green,
                  decoration: _inputDecoration('メールアドレスを入力'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addOrEditEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('保存'),
                ),
              ],
            ),
            emptyText: 'メールアドレスは登録されていません',
            addText: '＋新しく登録',
            onRemove: _removeEmail,
            onEdit: _editEmail,
          ),

          // CARDS
          _buildSection(
            title: 'クレジットカード',
            items: creditCards,
            onAdd: () => setState(() => showCardForm = !showCardForm),
            showForm: showCardForm,
            formWidget: Column(
              children: [
                TextField(
                  controller: _cardNameController,
                  style: const TextStyle(color: green),
                  cursorColor: green,
                  decoration: _inputDecoration('カード名義人'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cardNumberController,
                  style: const TextStyle(color: green),
                  cursorColor: green,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('カード番号(16桁)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cardExpiryController,
                  style: const TextStyle(color: green),
                  cursorColor: green,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('有効期限(MM/YY)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cardPhoneController,
                  style: const TextStyle(color: green),
                  cursorColor: green,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('電話番号'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addOrEditCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('保存'),
                ),
              ],
            ),
            emptyText: 'クレジットカードは登録されていません',
            addText: '＋新しく登録',
            onRemove: _removeCard,
            onEdit: _editCard,
          ),

          // ADDRESSES
          _buildSection(
            title: '配送先住所',
            items: addresses,
            onAdd: () => setState(() => showAddressForm = !showAddressForm),
            showForm: showAddressForm,
            formWidget: Column(
              children: [
                TextField(
                  controller: _addressController,
                  style: const TextStyle(color: green),
                  cursorColor: green,
                  decoration: _inputDecoration('住所を入力'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addOrEditAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('保存'),
                ),
              ],
            ),
            emptyText: '住所は登録されていません',
            addText: '＋新しく登録',
            onRemove: _removeAddress,
            onEdit: _editAddress,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
