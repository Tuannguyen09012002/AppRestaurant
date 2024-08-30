import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Manager/add_order_screen.dart';
import '../Manager/manage_menu_screen.dart';

class MonAn {
  final String key;
  final String tenMon;
  final int soLuong;
  final int ban;
  final String trangThai;

  MonAn({
    required this.key,
    required this.tenMon,
    required this.soLuong,
    required this.ban,
    required this.trangThai,
  });
}

class ManHinhQuanLy extends StatefulWidget {
  @override
  _ManHinhQuanLyState createState() => _ManHinhQuanLyState();
}

class _ManHinhQuanLyState extends State<ManHinhQuanLy> {
  List<MonAn> danhSachMonAn = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('order1');
    ordersRef.onValue.listen((DatabaseEvent event) {
      var snapshot = event.snapshot.value as Map<dynamic, dynamic>?;

      if (snapshot == null) {
        return;
      }

      List<MonAn> newDanhSachMonAn = [];
      snapshot.forEach((key, value) {
        var order = value as Map<dynamic, dynamic>;
        int ban = int.parse(order['tableNumber']);
        String tenMon = order['itemName'];
        int soLuong = order['itemCount'];
        String trangThai = order.containsKey('status') ? order['status'] : 'Chưa lên';
        MonAn monAn = MonAn(
          key: key,
          tenMon: tenMon,
          soLuong: soLuong,
          ban: ban,
          trangThai: trangThai,
        );
        newDanhSachMonAn.insert(0, monAn);
      });

      setState(() {
        danhSachMonAn = newDanhSachMonAn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int rowIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Tên bàn')),
              DataColumn(label: Text('Tên món')),
              DataColumn(label: Text('Trạng thái')),
              DataColumn(label: Text('Số lượng')),
            ],
            rows: danhSachMonAn.map((monAn) {
              return DataRow(
                color: MaterialStateColor.resolveWith((states) {
                  return rowIndex++ % 2 == 0 ? Colors.white : Colors.green[100]!;
                }),
                cells: [
                  DataCell(Text('Bàn ${monAn.ban}')),
                  DataCell(Text(monAn.tenMon)),
                  DataCell(Text(monAn.trangThai)),
                  DataCell(Text(monAn.soLuong.toString())),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.home, size: 40),
                  onPressed: () {
                  },
                ),
                SizedBox(width: 60),
                IconButton(
                  icon: Icon(Icons.menu, size: 40),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManageMenuScreen()),
                    );
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddOrderScreen()),
                  );
                },
                child: Icon(Icons.add, size: 40),
                elevation: 4.0,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
