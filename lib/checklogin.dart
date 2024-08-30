import 'package:flutter/material.dart';
import 'services/data.dart';

void onLogin(String username, String password, String role, BuildContext context) {
  if (isValidRole(role)) {
    if (checkCredentials(username, password, role)) {
      navigateToRolePage(context, role);
    } else {
      check(context, 'Tài khoản hoặc mật khẩu không đúng.', username, password, role);
    }
  } else {
    check(context, 'Tài khoản hoặc mật khẩu không đúng.', username, password, role);
  }
}

bool isValidRole(String role) {
  return AccountDatabase.accounts.containsKey(role);
}

bool checkCredentials(String username, String password, String role) {
  return AccountDatabase.accounts[role]!['username'] == username &&
      AccountDatabase.accounts[role]!['password'] == password;
}

void navigateToRolePage(BuildContext context, String role) {
  Navigator.pushReplacementNamed(context, '/$role');
}

void check(BuildContext context, String message, String username, String password, String role) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Lỗi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            SizedBox(height: 8),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Đóng'),
          ),
        ],
      );
    },
  );
}
