// lib/data/order_history.dart
import 'menu_data.dart';
import 'cart.dart'; // Para acessar CartItem

// Cada pedido mantém itens e quantidade, além do número do pedido
class OrderHistoryItem {
  final int orderId; // ✅ número do pedido
  final MenuItem item;
  int quantity;

  OrderHistoryItem({
    required this.orderId,
    required this.item,
    required this.quantity,
  });
}

// Lista global do histórico de pedidos
List<OrderHistoryItem> orderHistory = [];

// Função para adicionar itens do carrinho ao histórico com orderId
void addOrderToHistory(List<CartItem> cartItems, {required int orderId}) {
  for (var c in cartItems) {
    try {
      // Tenta encontrar item existente no mesmo pedido
      final existing = orderHistory.firstWhere(
        (o) => o.item.id == c.item.id && o.orderId == orderId,
      );
      existing.quantity += c.quantity;
    } catch (e) {
      // Se não encontrar, adiciona novo item
      orderHistory.add(
        OrderHistoryItem(orderId: orderId, item: c.item, quantity: c.quantity),
      );
    }
  }
}
