import 'package:flutter/material.dart';
import '../Cashier/revenue_management_screen.dart';
import '../Cashier/table_detail_screen.dart';
import '../services/change_password_screen.dart'; // Thêm import này



class ManHinhThuNgan extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            const Spacer(),
            const Text('Thu Ngân'),
            const Spacer(),
          ],
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: const Text('Quản lý doanh thu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RevenueManagementScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Đổi mật khẩu'), // Thay đổi tên mục
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage(role:'cashier')),
                );
              },
            ),
            ListTile(
              title: const Text('Đăng xuất'),
              onTap: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 4 / 3,
                ),
                itemBuilder: (context, index) {
                  return RestaurantTable(index: index);
                },
                itemCount: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantTable extends StatelessWidget {
  final int index;

  RestaurantTable({required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TableDetailScreen(tableNumber: index + 1),
          ),
        ).then((value) {
          print('Điều hướng thành công');
        }).catchError((error) {
          print('Lỗi điều hướng: $error');
        });
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[500],
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TableIcon(),
            const SizedBox(height: 10.0),
            Text(
              'Bàn ${index + 1}',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class TableIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/ban.png', width: 80.0, height: 80.0);
  }
}
