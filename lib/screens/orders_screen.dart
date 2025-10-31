import 'package:flutter/material.dart';
import '../data/cart.dart';
import '../data/menu_data.dart';
import '../data/order.dart';
import '../data/order_history.dart';
import '../data/kitchen_orders.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'order_screen_history.dart';
import 'mypage_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedBottomIndex = 1;

  void _removeItem(MenuItem item) {
    removeFromCart(item);
    setState(() {});
  }

  String formatPrice(double price) => '¥${price.toStringAsFixed(0)}';

  int getNextOrderId() {
    if (kitchenOrders.isEmpty) return 1;
    final maxId = kitchenOrders
        .map((o) => o.id)
        .reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  Future<void> _confirmOrder() async {
    if (cart.isEmpty) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('レジに進む', style: TextStyle(color: Color(0xFF1A4D2E))),
        backgroundColor: const Color(0xFFE5E9EC),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1A4D2E),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('いいえ'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1A4D2E),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('はい'),
          ),
        ],
      ),
    );

    if (result == true) {
      final orderId = getNextOrderId();
      final orderItems = cart
          .map((c) => OrderItem(item: c.item, quantity: c.quantity))
          .toList();

      final newOrder = Order(
        id: orderId,
        items: orderItems,
        createdAt: DateTime.now(),
      );

      kitchenOrders.add(newOrder);
      addOrderToHistory(cart, orderId: orderId);
      cart.clear();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ご注文ありがとうございました！'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _onBottomNavTap(int index) {
    if (_selectedBottomIndex == index) return;
    setState(() => _selectedBottomIndex = index);

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
      backgroundColor: const Color(0xFFE5E9EC),
      appBar: AppBar(
        title: const Text('カート', style: TextStyle(color: Color(0xFF1A4D2E))),
        centerTitle: true,
        backgroundColor: const Color(0xFFE5E9EC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A4D2E)),
      ),
      body: cart.isEmpty
          ? const Center(
              child: Text(
                'カートは空です',
                style: TextStyle(color: Color(0xFF1A4D2E)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final c = cart[index];
                final priceText =
                    '${c.quantity} x ${formatPrice(c.item.price)}';
                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(c.item.imagePath, fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(
                    c.item.labelKey,
                    style: const TextStyle(color: Color(0xFF1A4D2E)),
                  ),
                  subtitle: Text(
                    priceText,
                    style: const TextStyle(color: Color(0xFF1A4D2E)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFF1A4D2E)),
                    onPressed: () => _removeItem(c.item),
                  ),
                );
              },
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFE5E9EC),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '合計: ¥${getCartTotal().toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A4D2E),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: cart.isEmpty ? null : _confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF307A59),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(100, 45),
                  ),
                  child: const Text('レジに進む'),
                ),
              ],
            ),
          ),
          CustomBottomNavBar(
            currentIndex: _selectedBottomIndex,
            onTap: _onBottomNavTap,
          ),
        ],
      ),
    );
  }
}
