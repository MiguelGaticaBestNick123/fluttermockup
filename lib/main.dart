// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/product_list_page.dart';
import 'pages/about_page.dart';
import 'pages/team_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prototipo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => LoginPage(),
        '/home': (_) => ProductListPage(),
        '/about': (_) => AboutPage(),
        '/team': (_) => TeamPage(),
      },
    );
  }
}