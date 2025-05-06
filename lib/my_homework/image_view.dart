import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hiển thị ảnh")),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Image.asset('assets/images/1.jpg'),
            ),
            Expanded(
              child: Image.asset('assets/images/2.jpg'),
            ),
            Expanded(
              child: Image.asset('assets/images/3.jpg'),
            ),
          ],
        ),
      ),
    );
  }
}