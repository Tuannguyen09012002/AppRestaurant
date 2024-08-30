import 'package:flutter/material.dart';
import 'package:APP401/services/data.dart';

class ChangePasswordPage extends StatefulWidget {
  final String role;

  ChangePasswordPage({required this.role});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _validateFields() {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showMessage('Vui lòng nhập mật khẩu hiện tại, mật khẩu mới và xác nhận mật khẩu mới');
      return;
    }

    if (_currentPasswordController.text.isEmpty) {
      _showMessage('Vui lòng nhập mật khẩu hiện tại');
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      _showMessage('Vui lòng nhập mật khẩu mới');
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _showMessage('Vui lòng nhập xác nhận mật khẩu mới');
      return;
    }
  }

  void _changePassword() {
    _validateFields();

    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    String role = widget.role;

    String? username = AccountDatabase.accounts[role]?['username'];

    if (username == null) {
      _showMessage('Không tìm thấy tài khoản cho vai trò này');
      return;
    }

    if (AccountDatabase.accounts[role]?['password'] != currentPassword) {
      _showMessage('Mật khẩu hiện tại không đúng');
      return;
    }


    if (newPassword != confirmPassword) {
      _showMessage('Mật khẩu mới và xác nhận mật khẩu không khớp');
      return;
    }


    setState(() {
      AccountDatabase.accounts[role]?['password'] = newPassword;
    });


    AccountDatabase.updateAccount(role, newPassword, role);

    _showMessage('Đổi mật khẩu thành công');
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: Icon(Icons.vpn_key),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nhập lại mật khẩu mới',
                prefixIcon: Icon(Icons.vpn_key),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Cập nhật mật khẩu'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
          ],
        ),
      ),
    );
  }
}
