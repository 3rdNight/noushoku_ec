import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    purchaseHistory.removeAt(index);
    await prefs.setStringList(
      'purchaseHistory',
      purchaseHistory.map((e) => jsonEncode(e)).toList(),
    );
    setState(() {});
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
          if (purchaseHistory.isEmpty)
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

              return Card(
                color: scaffoldBg.withOpacity(0.95),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                            color: green,
                          ),
                        ),
                      ),
                      const Divider(thickness: 2),

                      // Produtos
                      ...order['items'].map<Widget>((item) {
                        double subtotal = item['price'] * item['quantity'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['label'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: green,
                                ),
                              ),
                              Text(
                                '¥${item['price'].toStringAsFixed(0)} × ${item['quantity']}',
                                style: const TextStyle(color: green),
                              ),
                              Text(
                                '小計: ¥${subtotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: green,
                                ),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      }).toList(),

                      // Total geral
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '合計: ¥${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Dados do cartão
                      Text(
                        'カード名義人: ${order['cardName'] ?? order['card']?['name'] ?? ''}',
                        style: const TextStyle(color: green),
                      ),
                      Text(
                        'カード番号: **** **** **** ${((order['cardNumber'] ?? order['card']?['number'] ?? '') as String).length >= 4 ? (order['cardNumber'] ?? order['card']?['number'] ?? '').substring(((order['cardNumber'] ?? order['card']?['number'] ?? '').length - 4)) : ''}',
                        style: const TextStyle(color: green),
                      ),

                      // Data/hora da compra formatada
                      if (order['dateTime'] != null &&
                          (order['dateTime'] as String).isNotEmpty)
                        Text(
                          '購入日時: ${DateTime.tryParse(order['dateTime']).toString().isNotEmpty ? "${DateTime.parse(order['dateTime']).year}年${DateTime.parse(order['dateTime']).month.toString().padLeft(2, '0')}月${DateTime.parse(order['dateTime']).day.toString().padLeft(2, '0')}日 ${DateTime.parse(order['dateTime']).hour.toString().padLeft(2, '0')}:${DateTime.parse(order['dateTime']).minute.toString().padLeft(2, '0')}" : ""}',
                          style: const TextStyle(color: green),
                        ),

                      // Endereço
                      Text(
                        '配送先住所: ${order['address']}',
                        style: const TextStyle(color: green),
                      ),

                      // Mensagem de presente
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
                                color: green,
                              ),
                            ),
                            Text(
                              order['giftMessage'],
                              style: const TextStyle(color: green),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: scaffoldBg,
                                title: const Text(
                                  '注文をキャンセルしますか？',
                                  style: TextStyle(
                                    color: green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16, // tamanho reduzido
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop(); // Fecha o dialog
                                    },
                                    child: const Text(
                                      'いいえ',
                                      style: TextStyle(color: green),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deletePurchase(index); // Deleta o pedido
                                      Navigator.of(ctx).pop(); // Fecha o dialog
                                    },
                                    child: const Text(
                                      'はい',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
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
