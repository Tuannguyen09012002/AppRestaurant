import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class QuanLyBanPage extends StatefulWidget {
  @override
  _QuanLyBanPageState createState() => _QuanLyBanPageState();
}

class _QuanLyBanPageState extends State<QuanLyBanPage> {
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref().child('order1');
  List<int> emptyTables = List.generate(8, (index) => index + 1);
  List<int> occupiedTables = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  void _fetchOrderData() {
    _ordersRef.onValue.listen((event) {
      Map<dynamic, dynamic>? orders = event.snapshot.value as Map<dynamic, dynamic>?;

      if (orders != null) {
        Set<int> occupied = {};
        Set<int> empty = Set.from(List.generate(8, (index) => index + 1));

        for (var order in orders.values) {
          int tableNumber = int.parse(order['tableNumber']);
          if (order['paymentStatus'] != 'đã thanh toán') {
            occupied.add(tableNumber);
            empty.remove(tableNumber);
          }
        }

        setState(() {
          occupiedTables = occupied.toList();
          emptyTables = empty.toList();
        });
      } else {
        setState(() {
          occupiedTables = [];
          emptyTables = List.generate(8, (index) => index + 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý bàn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bàn trống:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTableList(context, emptyTables, Colors.green[100]),
            const SizedBox(height: 16),
            const Text(
              'Bàn có khách:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTableList(context, occupiedTables, Colors.red[100]),
          ],
        ),
      ),
    );
  }

  Widget _buildTableList(BuildContext context, List<int> tables, Color? color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tables.map((tableNumber) => _buildTableItem(context, tableNumber, color)).toList(),
    );
  }

  Widget _buildTableItem(BuildContext context, int tableNumber, Color? color) {
    return GestureDetector(
      onTap: () {

      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TableIcon(),
              const SizedBox(height: 10.0),
              Text(
                'Bàn $tableNumber',
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TableIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/ban.png', width: 60.0, height: 60.0);
  }
}
