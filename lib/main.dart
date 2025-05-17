import 'package:flutter/material.dart';
import 'package:post365/LoginPage/login_page.dart';
import 'package:post365/LoginPage/register_page.dart';

void main() => runApp(const POS365Login());

class POS365Login extends StatelessWidget {
  const POS365Login({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'POS365',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
