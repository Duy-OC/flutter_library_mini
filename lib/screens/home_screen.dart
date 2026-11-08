import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import 'book_grid_screen.dart';
import 'book_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.repository});

  final BookRepository? repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          BookListScreen(repository: widget.repository),
          BookGridScreen(repository: widget.repository),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) => setState(() => _selectedIndex = index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.view_list), label: 'Danh sách'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Lưới'),
        ],
      ),
    );
  }
}
