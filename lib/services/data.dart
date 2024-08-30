import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class AccountDatabase {
  static DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('accounts');

  static Map<String, Map<String, String>> accounts = {
    'waiter': {
      'username': 'nhanvien',
      'password': '123',
      'role': 'waiter',
      'email': '',
    },
    'kitchen': {
      'username': 'bep',
      'password': '123',
      'role': 'kitchen',
      'email': 'tuannguyennguyen0901@gmail.com',
    },
    'cashier': {
      'username': 'thungan',
      'password': '123',
      'role': 'cashier',
      'email': 'tuannguyen0912002@gmail.com',
    },
    'manager': {
      'username': 'quanly',
      'password': '123',
      'role': 'manager',
      'email': 'tuannguyen0912002@gmail.com',
    },
  };

  static String? getRoleByEmail(String email) {
    for (var role in accounts.keys) {
      if (accounts[role]!['email'] == email) {
        return role;
      }
    }
    return null;
  }

  static void updateAccount(String role, String newPassword, String newRole) {
    String? usernameToUpdate = accounts[role]?['username'];

    if (usernameToUpdate != null) {
      Map<String, dynamic> newData = {
        'password': newPassword,
        'role': newRole,
      };

      _databaseReference.child(usernameToUpdate).update(newData);
    } else {
      print('Error: Username not found for role $role');
    }
  }

  static void updatePasswordForRole(String role, String newPassword) {
    String? usernameToUpdate = accounts[role]?['username'];

    if (usernameToUpdate != null) {
      Map<String, dynamic> newData = {
        'password': newPassword,
      };

      _databaseReference.child(usernameToUpdate).update(newData);
    } else {
      print('Error: Username not found for role $role');
    }
  }

  static String generateRandomPassword(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return List.generate(length, (index) => chars[rnd.nextInt(chars.length)]).join();
  }
}
