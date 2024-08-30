import 'package:flutter/material.dart';
import 'order.dart';

class ReceiptScreen extends StatelessWidget {
  final List<Order> orders;

  ReceiptScreen({required this.orders});

  @override
  Widget build(BuildContext context) {
    int totalAmount = orders.fold(0, (total, order) => total + (order.itemPrice * order.itemCount).toInt());

    return Scaffold(
      appBar: AppBar(
        title: const Text('In hóa đơn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HÓA ĐƠN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Divider(),
            const Text('Tên món', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Số lượng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Giá', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Thành tiền', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  Order order = orders[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.itemName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${order.itemCount}', style: const TextStyle(fontSize: 16)),
                          Text('${order.itemPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16)),
                          Text('${(order.itemPrice * order.itemCount).toStringAsFixed(0)} VND', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
            const Divider(),
            Text(
              'Tổng cộng: $totalAmount VND',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
