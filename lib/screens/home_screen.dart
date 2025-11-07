import 'package:flutter/material.dart';
import 'dish_detail_screen.dart';
import '../data/menu_data.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'orders_screen.dart';
import 'order_screen_history.dart';
import 'mypage_screen.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedBottomIndex = 0;
  int _selectedCategoryIndex = 0;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color scaffoldBg = Color(0xFFE5E9EC);

  late final List<String> categories = [
    'すべて',
    ...{...foodsMenu.map((item) => item.subcategory)},
  ].toList();

  List<MenuItem> get filteredDishes {
    if (_selectedCategoryIndex == 0) {
      return [...foodsMenu];
    }
    final subcat = categories[_selectedCategoryIndex];
    return foodsMenu.where((item) => item.subcategory == subcat).toList();
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

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 50,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = index == _selectedCategoryIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: scaffoldBg,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF307A59), width: 2)
                      : null,
                ),
                child: Text(
                  categories[index],
                  style: const TextStyle(
                    color: Color(0xFF1A4D2E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDishGrid() {
    const int itemsPerPage = 4;
    final int pageCount = (filteredDishes.length / itemsPerPage).ceil();

    return Expanded(
      child: Stack(
        children: [
          PageView.builder(
            itemCount: pageCount,
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * itemsPerPage;
              final endIndex =
                  (startIndex + itemsPerPage > filteredDishes.length)
                  ? filteredDishes.length
                  : startIndex + itemsPerPage;
              final pageItems = filteredDishes.sublist(startIndex, endIndex);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: pageItems.length,
                  itemBuilder: (context, index) {
                    final dish = pageItems[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DishDetailScreen(dish: dish),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: AssetImage(dish.imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dish.labelKey,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A4D2E),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A4D2E)),
              onPressed: _currentPage > 0
                  ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                  : null,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF1A4D2E),
              ),
              onPressed: _currentPage < pageCount - 1
                  ? () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        _buildCategorySelector(),
        const SizedBox(height: 16),
        _buildDishGrid(),
      ],
    );
  }

  Widget _homeContent() {
    return SafeArea(
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final logoHeight = constraints.maxWidth * 0.15; // 15% da largura
              return Container(
                color: scaffoldBg,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: logoHeight.clamp(50, 80), // min 50, max 80
                  ),
                ),
              );
            },
          ),
          Expanded(child: _buildHomeTab()),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: _homeContent(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
