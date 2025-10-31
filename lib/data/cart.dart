import 'menu_data.dart';

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});
}

List<CartItem> cart = [];

void addToCart(MenuItem item) {
  final index = cart.indexWhere((c) => c.item.id == item.id);
  if (index >= 0) {
    cart[index].quantity += 1;
  } else {
    cart.add(CartItem(item: item));
  }
}

void removeFromCart(MenuItem item) {
  cart.removeWhere((c) => c.item.id == item.id);
}

double getCartTotal() {
  return cart.fold(0, (sum, c) => sum + (c.item.price * c.quantity));
}
