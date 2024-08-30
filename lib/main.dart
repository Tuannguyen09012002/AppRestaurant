import 'package:flutter/material.dart';
import 'package:APP401/home_page.dart';
import 'checklogin.dart';
import 'login_form.dart';
import 'menuitem.dart';
import 'model/kitchen_screen.dart';
import 'model/Waitstaff_screen.dart';
import 'model/Management_screen.dart';
import 'model/Cashier_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  static String? selectedRole;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SelectRolePage(),
        '/login': (context) => LoginForm(
          onLogin: (username, password, role) {
            onLogin(username, password, role, context);
          },
          role: selectedRole ?? '',
          usernameController: _usernameController,
          passwordController: _passwordController,
          initialUsername: '',
        ),
        '/waiter': (context) => ManHinhNhanVienPhucVu(item: MenuItem.fooddata[0]),
        '/kitchen': (context) => ManHinhBep(),
        '/cashier': (context) => ManHinhThuNgan(),
        '/manager': (context) => ManHinhQuanLy(),
      },
    );
  }
}


