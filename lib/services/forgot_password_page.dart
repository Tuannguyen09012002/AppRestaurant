import 'package:flutter/material.dart';
import 'package:APP401/services/data.dart'; // Đảm bảo rằng đường dẫn này đúng với tệp 'data.dart' của bạn
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String role;

  ForgotPasswordPage({required this.role});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  String? errorText;

  Future<void> sendPasswordResetEmail() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        errorText = "Vui lòng nhập email.";
      });
      return;
    }

    // Kiểm tra xem email có trùng với role không
    if (AccountDatabase.accounts[widget.role]!['email'] != email) {
      setState(() {
        errorText = "Email không trùng khớp với role.";
      });
      return;
    }

    try {
      // Tạo mật khẩu ngẫu nhiên
      String newPassword = AccountDatabase.generateRandomPassword(8);

      // Cập nhật mật khẩu trong cơ sở dữ liệu
      AccountDatabase.updatePasswordForRole(widget.role, newPassword);

      // Gửi email với mật khẩu mới
      await sendEmail(email, newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mật khẩu mới đã được gửi đến $email")),
      );
      setState(() {
        errorText = null;
      });
    } catch (e) {
      print('Error sending password reset email: $e');
      setState(() {
        errorText = "Không thể gửi email đặt lại mật khẩu. Vui lòng kiểm tra lại email của bạn.";
      });
    }
  }

  Future<void> sendEmail(String email, String newPassword) async {
    final smtpServer = gmail('tuannguyenak0901@gmail.com', '01685441883lam'); // Sử dụng email và mật khẩu của bạn
    final message = Message()
      ..from = Address('your_email@gmail.com', 'Your App Name')
      ..recipients.add(email)
      ..subject = 'Đặt lại mật khẩu'
      ..text = 'Mật khẩu mới của bạn là $newPassword';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Message not sent. \n'+ e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quên mật khẩu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Nhập email của bạn",
                errorText: errorText,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendPasswordResetEmail,
              child: Text("Đặt lại mật khẩu"),
            ),
          ],
        ),
      ),
    );
  }
}
