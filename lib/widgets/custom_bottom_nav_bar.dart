import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = const Color(0xFFE5E9EC);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: scaffoldBg,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedItemColor: const Color(0xFF307A59),
      unselectedItemColor: const Color(0xFF1A4D2E),
      items: [
        _buildNavItem(0, Icons.home, 'ホーム', scaffoldBg), // Home
        _buildNavItem(1, Icons.shopping_cart, 'カート', scaffoldBg), // Carrinho
        _buildNavItem(2, Icons.payment, 'チェックアウト', scaffoldBg), // Checkout
        _buildNavItem(3, Icons.person, 'マイページ', scaffoldBg), // MyPage
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color scaffoldBg,
  ) {
    final isSelected = index == currentIndex;

    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scaffoldBg,
          border: isSelected
              ? Border.all(color: const Color(0xFF307A59), width: 2)
              : null,
        ),
        child: Icon(icon, color: const Color(0xFF1A4D2E), size: 22),
      ),
      label: label,
    );
  }
}
