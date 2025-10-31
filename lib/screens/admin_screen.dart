import 'package:flutter/material.dart';
import '../data/kitchen_orders.dart';
import '../data/order.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  void _markAsDone(Order order) {
    setState(() {
      kitchenOrders.remove(order);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '注文番号 ${order.id.toString().padLeft(4, '0')} を完了にしました。',
          style: const TextStyle(color: Color(0xFF1A4D2E)),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFFE5E9EC),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E9EC),
      appBar: AppBar(
        title: const Text(
          '管理者画面',
          style: TextStyle(
            color: Color(0xFF1A4D2E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE5E9EC),
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1A4D2E)),
      ),
      body: kitchenOrders.isEmpty
          ? const Center(
              child: Text(
                '現在、注文はありません。',
                style: TextStyle(fontSize: 18, color: Color(0xFF1A4D2E)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: kitchenOrders.length,
              itemBuilder: (context, index) {
                final order = kitchenOrders[index];
                final timeStr = order.createdAt.toString().substring(0, 19);

                // Total do pedido
                final totalOrder = order.items.fold<double>(
                  0,
                  (sum, oi) => sum + (oi.item.price * oi.quantity),
                );

                return Card(
                  color: const Color(0xFFE5E9EC),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cabeçalho
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '注文番号: ${order.id.toString().padLeft(4, '0')}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A4D2E),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: order.status == '完了'
                                    ? Colors.grey
                                    : const Color(0xFF307A59),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '時間: $timeStr',
                          style: const TextStyle(color: Color(0xFF1A4D2E)),
                        ),
                        const Divider(color: Color(0xFF1A4D2E)),
                        const Text(
                          '🧾 注文内容:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1A4D2E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Lista de itens com nome e preço unitário × quantidade
                        ...order.items.map(
                          (oi) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    oi.item.labelKey,
                                    style: const TextStyle(
                                      color: Color(0xFF1A4D2E),
                                    ),
                                  ),
                                ),
                                Text(
                                  '¥${oi.item.price.toStringAsFixed(0)} ×${oi.quantity}',
                                  style: const TextStyle(
                                    color: Color(0xFF1A4D2E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Total do pedido
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              '合計: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1A4D2E),
                              ),
                            ),
                            Text(
                              '¥${totalOrder.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1A4D2E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (order.status != '完了')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF307A59),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 45),
                              ),
                              onPressed: () => _markAsDone(order),
                              child: const Text('完了にする'),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
