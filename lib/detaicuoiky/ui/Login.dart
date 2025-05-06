import 'package:flutter/material.dart';
import 'TaskList.dart';
import 'Authservice.dart';
import 'Register.dart';
import 'ForgotPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    // ✅ Kiểm tra người dùng đã nhập email và mật khẩu chưa
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ email và mật khẩu")),
      );
      setState(() => _isLoading = false);
      return;
    }

    final success = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success) {
      final userModel = _authService.currentUser;
      if (userModel != null) {
        // ✅ Hiển thị thông báo đăng nhập thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng nhập thành công!")),
        );

        // ✅ Đợi 1s để SnackBar hiển thị
        await Future.delayed(Duration(seconds: 1));

        // ✅ Điều hướng đến TaskListScreen (HomeScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(currentUser: userModel),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không tìm thấy dữ liệu người dùng!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sai email hoặc mật khẩu!")),
      );
    }

    setState(() => _isLoading = false);
  }

  // Chuyển đến màn hình đăng ký
  void _goToRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chào mừng bạn trở lại 👋",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Vui lòng đăng nhập để tiếp tục",
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                child: Text('Quên mật khẩu?', style: TextStyle(color: Colors.blueAccent)),
              ),
            ),
            SizedBox(height: 12),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Đăng nhập", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: _goToRegisterScreen,
                child: Text("Chưa có tài khoản? Đăng ký ngay!", style: TextStyle(color: Colors.black87)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}