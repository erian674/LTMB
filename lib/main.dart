import 'package:flutter/material.dart';
import '../detaicuoiky/ui/Login.dart';
import '../detaicuoiky/ui/ChangePasswordScreen.dart';
import '../detaicuoiky/ui/ForgotPasswordScreen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý công việc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
      },
    );
  }
}