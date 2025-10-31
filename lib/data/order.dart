import 'menu_data.dart';

class OrderItem {
  final MenuItem item;
  final int quantity;

  OrderItem({required this.item, required this.quantity});
}

class Order {
  final int id;
  final List<OrderItem> items;
  final DateTime createdAt;
  String status;

  Order({
    required this.id,
    required this.items,
    required this.createdAt,
    this.status = '調理中', // padrão: em preparo
  });

  double get totalPrice =>
      items.fold(0, (sum, oi) => sum + (oi.item.price * oi.quantity));
}
