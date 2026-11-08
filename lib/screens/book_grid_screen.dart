import 'dart:math';

import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_view.dart';
import 'book_detail_screen.dart';

class BookGridScreen extends StatefulWidget {
  const BookGridScreen({super.key, this.repository});

  final BookRepository? repository;

  @override
  State<BookGridScreen> createState() => _BookGridScreenState();
}

class _BookGridScreenState extends State<BookGridScreen> {
  late Future<List<Book>> _books;
  BookRepository get _repository => widget.repository ?? bookRepository;

  @override
  void initState() {
    super.initState();
    _books = _repository.loadBooks();
  }

  void _retry() {
    setState(() => _books = _repository.refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thư viện mini'), centerTitle: true),
      body: FutureBuilder<List<Book>>(
        future: _books,
        builder: (BuildContext context, AsyncSnapshot<List<Book>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const EmptyView(message: 'Không đọc được dữ liệu sách.'),
                  TextButton(onPressed: _retry, child: const Text('Thử lại')),
                ],
              ),
            );
          }
          final List<Book> books = snapshot.data ?? const <Book>[];
          if (books.isEmpty) {
            return const EmptyView(message: 'Chưa có sách trong dữ liệu.');
          }
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int columns = constraints.maxWidth < 350
                  ? 1
                  : max(2, ((constraints.maxWidth + 8) / 190).floor());
              return GridView.builder(
                key: const Key('book-grid'),
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: 250,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: books.length,
                itemBuilder: (BuildContext context, int index) {
                  final Book book = books[index];
                  return BookCard(
                    book: book,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BookDetailScreen(book: book),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
