import 'package:flutter/material.dart';
import 'main.dart';

class SelectRolePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/app.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chọn Vai Trò',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),
                  RoleOption(
                    role: 'Nhân Viên Phục Vụ',
                    color: Color(0xFF2196F3),
                    icon: Icons.restaurant_menu,
                    onPressed: () => _selectRoleAndNavigate(context, 'waiter'),
                  ),
                  SizedBox(height: 20),
                  RoleOption(
                    role: 'Bếp',
                    color: Color(0xFF4CAF50),
                    icon: Icons.kitchen,
                    onPressed: () => _selectRoleAndNavigate(context, 'kitchen'),
                  ),
                  SizedBox(height: 20),
                  RoleOption(
                    role: 'Thu Ngân',
                    color: Color(0xFFF44336),
                    icon: Icons.attach_money,
                    onPressed: () => _selectRoleAndNavigate(context, 'cashier'),
                  ),
                  SizedBox(height: 20),
                  RoleOption(
                    role: 'Quản Lý',
                    color: Color(0xFF9C27B0),
                    icon: Icons.supervisor_account,
                    onPressed: () => _selectRoleAndNavigate(context, 'manager'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectRoleAndNavigate(BuildContext context, String role) {
    MyApp.selectedRole = role;
    Navigator.pushNamed(context, '/login');
  }
}

class RoleOption extends StatelessWidget {
  final String role;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const RoleOption({
    required this.role,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 300,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              role,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
