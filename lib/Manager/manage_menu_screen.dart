import 'package:flutter/material.dart';
import 'package:APP401/Cashier/revenue_management_screen.dart';
import 'delete_menu_item_screen.dart';
import 'adjust_price_screen.dart';
import 'package:APP401/services/change_password_screen.dart';

class ManageMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.attach_money, 'label': 'Quản lý doanh thu', 'screen': RevenueManagementScreen()},
      {'icon': Icons.delete, 'label': 'Xóa món ăn khỏi danh sách', 'screen': DeleteMenuItemPage(onDelete: (MenuItem) {}),},
      {'icon': Icons.monetization_on, 'label': 'Chỉnh giá món ăn', 'screen': AdjustPriceScreen()},
      {'icon': Icons.lock, 'label': 'Đổi mật khẩu', 'screen': ChangePasswordPage(role: 'manager')},
      {'icon': Icons.exit_to_app, 'label': 'Đăng xuất', 'screen': null},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý hệ thống'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: InkWell(
                onTap: () {
                  _handleMenuOption(context, item['label'], item['screen']);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'],
                      size: 50,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['label'],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleMenuOption(BuildContext context, String label, Widget? screen) {
    if (label == 'Đăng xuất') {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } else if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }
}
