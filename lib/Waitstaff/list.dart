import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MonAn {
  final String key;
  final String tenMon;
  final int soLuong;
  final int ban;
  final int index;
  String trangThai;

  MonAn({
    required this.key,
    required this.tenMon,
    required this.soLuong,
    required this.ban,
    required this.index,
    this.trangThai = 'Chưa lên',
  });
}

class DanhSachDonHangCho extends StatefulWidget {
  @override
  _DanhSachDonHangChoState createState() => _DanhSachDonHangChoState();
}

class _DanhSachDonHangChoState extends State<DanhSachDonHangCho> {
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
      int globalIndex = 0;

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
          index: globalIndex++,
          trangThai: trangThai,
        );
        newDanhSachMonAn.add(monAn);
      });

      newDanhSachMonAn.sort((a, b) {
        if (a.trangThai == 'đã lên' && b.trangThai != 'đã lên') {
          return 1;
        } else if (a.trangThai != 'đã lên' && b.trangThai == 'đã lên') {
          return -1;
        } else {
          return a.index.compareTo(b.index);
        }
      });

      setState(() {
        danhSachMonAn = newDanhSachMonAn;
      });
    });
  }

  void hoanThanhMonAn(String key, int ban, String tenMon) {
    setState(() {
      MonAn? monAn = danhSachMonAn.firstWhere((ma) => ma.key == key);
      if (monAn != null) {
        monAn.trangThai = 'đã lên';
      }
    });

    DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('order1');
    ordersRef.child(key).update({'status': 'đã lên'});
  }

  void xoaMonAn(String key) {
    setState(() {
      danhSachMonAn.removeWhere((monAn) => monAn.key == key);
    });

    DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('order1');
    ordersRef.child(key).remove();
  }

  @override
  Widget build(BuildContext context) {
    int rowIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách đơn hàng chờ'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Tên bàn')),
              DataColumn(label: Text('Tên món')),
              DataColumn(label: Text('Số lượng')),
              DataColumn(label: Text('Trạng thái')),
              DataColumn(label: Text('Hành động')),
            ],
            rows: danhSachMonAn.map((monAn) {
              return DataRow(
                color: MaterialStateColor.resolveWith((states) {
                  return rowIndex++ % 2 == 0 ? Colors.white : Colors.green[100]!;
                }),
                cells: [
                  DataCell(Text('Bàn ${monAn.ban}')),
                  DataCell(Text(monAn.tenMon)),
                  DataCell(Text(monAn.soLuong.toString())),
                  DataCell(Text(monAn.trangThai)),
                  DataCell(
                    Row(
                      children: [
                        if (monAn.trangThai == 'đang lên')
                          ElevatedButton(
                            onPressed: () => hoanThanhMonAn(monAn.key, monAn.ban, monAn.tenMon),
                            child: Text('Hoàn thành'),
                          ),
                        if (monAn.trangThai == 'chưa lên')
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Xác nhận xóa'),
                                    content: Text('Bạn có chắc muốn xóa món này không?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          xoaMonAn(monAn.key);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Xóa'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
