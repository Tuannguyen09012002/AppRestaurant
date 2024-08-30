import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseReference ordersRef = FirebaseDatabase.instance.reference().child('order1');
  late List<Order> _todayOrders;
  late String _today;

  @override
  void initState() {
    super.initState();
    _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _todayOrders = [];
    _fetchTodayOrders();
  }

  Future<void> _fetchTodayOrders() async {
    ordersRef.onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? ordersMap = snapshot.value as Map<dynamic, dynamic>?;
      if (ordersMap != null) {
        List<Order> todayOrders = [];
        ordersMap.forEach((key, value) {
          Order order = Order.fromMap(Map<String, dynamic>.from(value));
          if (order.completedAt == _today) {
            todayOrders.add(order);
          }
        });
        setState(() {
          _todayOrders = todayOrders;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng hôm nay'),
      ),
      body: _todayOrders.isEmpty
          ? Center(child: Text('Chưa có đơn hàng nào trong hôm nay'))
          : ListView.builder(
        itemCount: _todayOrders.length,
        itemBuilder: (context, index) {
          Order order = _todayOrders[index];
          return ListTile(
            title: Text('Món: ${order.itemName}'),
            subtitle: Text('Số lượng: ${order.itemCount} - Bàn: ${order.tableNumber}'),
          );
        },
      ),
    );
  }
}

class Order {
  final String itemName;
  final int itemCount;
  final String time;
  final String completedAt;
  final String tableNumber;

  Order({
    required this.itemName,
    required this.itemCount,
    required this.time,
    required this.completedAt,
    required this.tableNumber,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      itemName: map['itemName'] ?? '',
      itemCount: map['itemCount'] ?? 0,
      time: map['time'] ?? '',
      completedAt: map['completedAt'] ?? '',
      tableNumber: map['tableNumber'] ?? '',
    );
  }
}
