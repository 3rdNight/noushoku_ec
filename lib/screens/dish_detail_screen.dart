import 'package:flutter/material.dart';
import '../data/cart.dart';
import '../data/menu_data.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'order_screen_history.dart';
import 'mypage_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class DishDetailScreen extends StatefulWidget {
  final MenuItem dish;
  const DishDetailScreen({super.key, required this.dish});

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  int quantity = 1;
  int _selectedBottomIndex = 0;

  void increment() => setState(() => quantity++);
  void decrement() =>
      setState(() => quantity = quantity > 1 ? quantity - 1 : 1);

  String formatPrice(double price) => '¥${price.toStringAsFixed(0)}';

  void _addToCart() {
    for (int i = 0; i < quantity; i++) {
      addToCart(widget.dish);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('カートに入れました！'),
        duration: Duration(seconds: 1),
      ),
    );
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
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;

    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = MediaQuery.of(context).size.width < 600;

    final imageHeight = isMobile
        ? screenHeight *
              0.40 // mobile
        : screenHeight * 0.25; // desktop

    return Scaffold(
      backgroundColor: const Color(0xFFE5E9EC),
      appBar: AppBar(
        title: Text(
          dish.labelKey,
          style: const TextStyle(color: Color(0xFF1A4D2E)),
        ),
        backgroundColor: const Color(0xFFE5E9EC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A4D2E)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔥 imagem corrigida — NÃO estica, NÃO corta, NÃO exagera no tamanho
              SizedBox(
                height: imageHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    dish.imagePath,
                    fit: BoxFit.contain, // a correção principal
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                dish.labelKey,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A4D2E),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                formatPrice(dish.price),
                style: const TextStyle(fontSize: 18, color: Color(0xFF1A4D2E)),
              ),

              const SizedBox(height: 16),

              Text(
                dish.descriptionKey,
                style: const TextStyle(fontSize: 16, color: Color(0xFF1A4D2E)),
                textAlign: TextAlign.justify,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: decrement,
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Color(0xFF1A4D2E),
                    ),
                  ),
                  Text(
                    quantity.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF1A4D2E),
                    ),
                  ),
                  IconButton(
                    onPressed: increment,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF1A4D2E),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('カートに入れる', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF307A59),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
