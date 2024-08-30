import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'order.dart';
import 'receipt_screen.dart';

class TableDetailScreen extends StatefulWidget {
  final int tableNumber;

  TableDetailScreen({required this.tableNumber});

  @override
  _TableDetailScreenState createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  bool _showNoOrders = false;
  late DatabaseReference _order1Ref;

  @override
  void initState() {
    super.initState();
    _order1Ref = FirebaseDatabase.instance.ref().child('order1');
    _startListeningToOrders();
  }

  void _startListeningToOrders() {
    _order1Ref.orderByChild('tableNumber').equalTo(widget.tableNumber.toString()).onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Order> orders = [];
      Map<dynamic, dynamic>? ordersMap = snapshot.value as Map<dynamic, dynamic>?;
      if (ordersMap != null) {
        ordersMap.forEach((key, value) {
          Order order = Order.fromMap(key, Map<String, dynamic>.from(value));
          if (order.paymentStatus != 'đã thanh toán') {
            if (order.status == 'chưa lên') {
              order.selected = false;
              orders.insert(0, order);
            } else {
              orders.add(order);
            }
          }
        });
      }
      setState(() {
        _orders = orders;
        _loading = false;
        _showNoOrders = _orders.isEmpty;
      });
    });
  }

  void _handlePayment() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận thanh toán'),
          content: const Text('Bạn có chắc chắn muốn thanh toán đơn hàng này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processPayment();
              },
              child: const Text('Thanh toán'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processPayment() async {
    String paymentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<Order> selectedOrders = _orders.where((order) => order.selected).toList();
    List<Order> nonSelectedOrders = _orders.where((order) => !order.selected).toList();

    List<Future> updateFutures = [];
    List<Future> deleteFutures = [];

    for (Order order in selectedOrders) {
      updateFutures.add(_order1Ref.child(order.id).update({
        'paymentStatus': 'đã thanh toán',
        'paymentDate': paymentDate,
      }));
    }

    for (Order order in nonSelectedOrders) {
      deleteFutures.add(_order1Ref.child(order.id).remove());
    }

    try {
      if (deleteFutures.isNotEmpty) {
        await Future.wait(deleteFutures);
      }

      if (updateFutures.isNotEmpty) {
        await Future.wait(updateFutures);
      }

      bool allOrdersPaid = selectedOrders.length == _orders.length;

      setState(() {
        if (allOrdersPaid) {
          _orders.clear();
        } else {
          _orders = nonSelectedOrders;
        }
        _showNoOrders = _orders.isEmpty;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanh toán thành công'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error during payment processing: $error');
    }
  }

  void _navigateToReceipt() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(orders: _orders),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng - Bàn ${widget.tableNumber}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PHIẾU THANH TOÁN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Bàn: ${widget.tableNumber}', style: const TextStyle(fontSize: 18)),
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
            _showNoOrders
                ? const Expanded(
              child: Center(
                child: Text('Không có đơn hàng nào.'),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  Order order = _orders[index];
                  return ReceiptItem(
                    order: order,
                    onSelected: (bool? value) {
                      setState(() {
                        order.selected = value ?? false;
                      });
                    },
                  );
                },
              ),
            ),
            const Divider(),
            Text(
              'Tổng cộng: ${_orders.where((order) => order.selected).fold(0, (total, order) => total + (order.itemPrice * order.itemCount).toInt())} VND',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _handlePayment,
                  child: const Text('Thanh toán'),
                ),
                ElevatedButton(
                  onPressed: _navigateToReceipt,
                  child: const Text('In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptItem extends StatelessWidget {
  final Order order;
  final ValueChanged<bool?> onSelected;

  const ReceiptItem({Key? key, required this.order, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(order.itemName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Checkbox(
              value: order.selected,
              onChanged: (bool? value) {
                order.selected = value ?? false;
                onSelected(value);
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
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
  }
}
