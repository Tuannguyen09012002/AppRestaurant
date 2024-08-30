import 'package:flutter/material.dart';
import 'package:APP401/services/forgot_password_page.dart';

class LoginForm extends StatefulWidget {
  static String tag = 'login-page';

  final void Function(String, String, String) onLogin;
  final String role;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final String? initialUsername;

  LoginForm({
    Key? key,
    required this.onLogin,
    required this.role,
    required this.usernameController,
    required this.passwordController,
    this.initialUsername,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String? errorText;

  @override
  void initState() {
    super.initState();
    widget.usernameController.text = widget.initialUsername ?? '';
    widget.passwordController.text = '';
  }

  void handleLogin() {
    String username = widget.usernameController.text;
    String password = widget.passwordController.text;

    if (username.isEmpty && password.isEmpty) {
      setState(() {
        errorText = "Vui lòng nhập tài khoản và mật khẩu.";
      });
    } else if (username.isEmpty) {
      setState(() {
        errorText = "Vui lòng nhập tài khoản.";
      });
    } else if (password.isEmpty) {
      setState(() {
        errorText = "Vui lòng nhập mật khẩu.";
      });
    } else {
      setState(() {
        errorText = null;
      });
      widget.onLogin(username, password, widget.role);
    }
  }

  void handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage(role: widget.role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 100.0, bottom: 10.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 100.0,
                        width: 100.0,
                        child: Hero(
                          tag: 'hero',
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 48.0,
                            child: Image.asset('assets/lock.jpg'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 40.0),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: widget.usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Nhập tài khoản',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Icon(
                        Icons.lock_open,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: widget.passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Nhập mật khẩu',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 30.0),
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue),
                      ),
                      onPressed: handleLogin,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                        child: Text(
                          "Đăng nhập",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: handleForgotPassword,
                      child: const Text(
                        "Quên mật khẩu?",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
