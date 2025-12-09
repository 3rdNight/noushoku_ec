import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'order_screen_history.dart';
import 'mypage_screen.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  static const Color green = Color(0xFF307A59);
  static const Color scaffoldBg = Color(0xFFE5E9EC);
  int _selectedBottomIndex = 3;

  List<Map<String, dynamic>> purchaseHistory = [];

  @override
  void initState() {
    super.initState();
    _loadPurchaseHistory();
  }

  Future<void> _loadPurchaseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('purchaseHistory') ?? [];
    setState(() {
      purchaseHistory = list
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList();
    });
  }

  Future<void> _deletePurchase(int index) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLoggedIn) {
      final id = purchaseHistory[index]['id'];
      if (id != null) await auth.removePurchase(id);
      // provider stream will refresh list; no local state change required
    } else {
      final prefs = await SharedPreferences.getInstance();
      purchaseHistory.removeAt(index);
      await prefs.setStringList(
        'purchaseHistory',
        purchaseHistory.map((e) => jsonEncode(e)).toList(),
      );
      setState(() {});
    }
  }

  Widget _buildOrderCard(
    BuildContext context,
    Map<String, dynamic> order,
    double total,
    bool remote, {
    int? index,
  }) {
    final Color green = const Color(0xFF307A59);
    final Color scaffoldBg = const Color(0xFFE5E9EC);

    return Card(
      color: scaffoldBg.withOpacity(0.95),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '注文番号: ${order['orderId']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF307A59),
                ),
              ),
            ),
            const Divider(thickness: 2),
            ...((order['items'] as List).map<Widget>((item) {
              double subtotal =
                  (item['price'] as num).toDouble() *
                  (item['quantity'] as num).toDouble();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['label'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF307A59),
                      ),
                    ),
                    Text(
                      '¥${(item['price'] as num).toDouble().toStringAsFixed(0)} × ${item['quantity']}',
                      style: const TextStyle(color: Color(0xFF307A59)),
                    ),
                    Text(
                      '小計: ¥${subtotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF307A59),
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              );
            })),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '合計: ¥${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF307A59),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (order['dateTime'] != null &&
                order['dateTime'].toString().isNotEmpty)
              Text(
                '購入日時: ${order['dateTime'].toString()}',
                style: const TextStyle(color: Color(0xFF307A59)),
              ),
            Text(
              '配送先住所: ${order['address']}',
              style: const TextStyle(color: Color(0xFF307A59)),
            ),
            if (order['recipientName'] != null &&
                order['recipientName'].toString().isNotEmpty)
              Text(
                '宛先名: ${order['recipientName']}',
                style: const TextStyle(color: Color(0xFF307A59)),
              ),
            if (order['giftMessage'] != null &&
                order['giftMessage'].toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'ギフトメッセージ:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF307A59),
                    ),
                  ),
                  Text(
                    order['giftMessage'],
                    style: const TextStyle(color: Color(0xFF307A59)),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  if (remote) {
                    final id = order['id'];
                    if (id != null) await auth.removePurchase(id);
                  } else {
                    if (index != null) await _deletePurchase(index);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
                child: const Text('キャンセル'),
              ),
            ),
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text('購入履歴', style: TextStyle(color: Color(0xFF1A4D2E))),
        backgroundColor: scaffoldBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Botões abaixo do título
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MyPageScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text('個人情報'),
                ),
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green.withOpacity(0.7),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text('購入履歴'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Corpo: lista de pedidos
          if (auth.isLoggedIn)
            ...auth.purchases.map((order) {
              final items = (order['items'] as List).cast<dynamic>();
              double total = 0;
              for (var item in items) {
                total +=
                    (item['price'] as num).toDouble() *
                    (item['quantity'] as num).toDouble();
              }

              return _buildOrderCard(context, order, total, true);
            }).toList()
          else if (purchaseHistory.isEmpty)
            const Center(
              child: Text(
                '購入履歴はありません',
                style: TextStyle(
                  color: Color(0xFF1A4D2E),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            ...purchaseHistory.asMap().entries.map((entry) {
              int index = entry.key;
              final order = entry.value;

              double total = 0;
              for (var item in order['items']) {
                total += item['price'] * item['quantity'];
              }

              return _buildOrderCard(
                context,
                order,
                total,
                false,
                index: index,
              );
            }).toList(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
