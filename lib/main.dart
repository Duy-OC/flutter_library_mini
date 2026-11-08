import 'package:flutter/material.dart';

import 'data/book_repository.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.repository});

  final BookRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thư viện mini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: HomeScreen(repository: repository),
    );
  }
}
