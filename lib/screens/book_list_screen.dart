import 'dart:math';

import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';
import '../widgets/book_tile.dart';
import '../widgets/empty_view.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key, this.repository});

  final BookRepository? repository;

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  static const int _pageSize = 20;
  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<Book> _allBooks = const <Book>[];
  int _visibleCount = 0;
  int _generation = 0;
  bool _isReading = true;
  bool _isLoadingMore = false;
  Object? _error;
  String _query = '';

  BookRepository get _repository => widget.repository ?? bookRepository;
  List<Book> get _results => searchBooks(_allBooks, _query);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _readBooks();
  }

  @override
  void dispose() {
    _generation++;
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _readBooks({bool refresh = false}) async {
    final int generation = ++_generation;
    setState(() {
      _isReading = true;
      _isLoadingMore = false;
      _error = null;
    });
    try {
      final List<Book> books =
          refresh ? await _repository.refresh() : await _repository.loadBooks();
      if (!mounted || generation != _generation) return;
      setState(() {
        _allBooks = books;
        _visibleCount = min(_pageSize, _results.length);
        _isReading = false;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _isReading = false;
      });
    }
  }

  void _changeQuery(String value) {
    _generation++;
    setState(() {
      _query = value;
      _visibleCount = min(_pageSize, _results.length);
      _isLoadingMore = false;
    });
    if (_controller.hasClients) _controller.jumpTo(0);
  }

  void _clearQuery() {
    _searchController.clear();
    _changeQuery('');
  }

  void _onScroll() {
    if (!_controller.hasClients || _isReading || _error != null) return;
    final ScrollPosition position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 200) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _visibleCount >= _results.length) return;
    final int generation = _generation;
    setState(() => _isLoadingMore = true);
    // Chỉ mô phỏng thời gian tải trang trên dữ liệu đã đọc trong bộ nhớ.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted || generation != _generation) return;
    setState(() {
      _visibleCount = min(_visibleCount + _pageSize, _results.length);
      _isLoadingMore = false;
    });
  }

  void _openDetail(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookDetailScreen(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Book> results = _results;
    final int visible = min(_visibleCount, results.length);
    return Scaffold(
      appBar: AppBar(title: const Text('Thư viện mini'), centerTitle: true),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              key: const Key('book-search-field'),
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _changeQuery,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên sách hoặc tác giả',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xóa tìm kiếm',
                        icon: const Icon(Icons.clear),
                        onPressed: _clearQuery,
                      ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
          ),
          if (!_isReading && _error == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Đã hiển thị $visible/${results.length} sách'),
              ),
            ),
          Expanded(child: _buildBody(results, visible)),
        ],
      ),
    );
  }

  Widget _buildBody(List<Book> results, int visible) {
    if (_isReading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _statusList(
        message: 'Không đọc được dữ liệu sách.',
        action: 'Thử lại',
        onPressed: () => _readBooks(refresh: true),
      );
    }
    if (_allBooks.isEmpty) {
      return _statusList(message: 'Chưa có sách trong dữ liệu.');
    }
    if (results.isEmpty) {
      return _statusList(
        message: 'Không tìm thấy sách',
        action: 'Xóa tìm kiếm',
        onPressed: _clearQuery,
      );
    }
    final bool showFeatured = _query.trim().isEmpty;
    final int prefixCount = showFeatured ? 1 : 0;
    return RefreshIndicator(
      onRefresh: () => _readBooks(refresh: true),
      child: ListView.builder(
        key: const Key('book-list'),
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: prefixCount + visible + 1,
        itemBuilder: (BuildContext context, int index) {
          if (showFeatured && index == 0) {
            return _FeaturedSection(
                books: _allBooks.take(10).toList(growable: false),
                onBookTap: _openDetail);
          }
          final int bookIndex = index - prefixCount;
          if (bookIndex < visible) {
            final Book book = results[bookIndex];
            return BookTile(
              key: ValueKey<String>(book.isbn13),
              book: book,
              onTap: () => _openDetail(book),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator()
                  : visible < results.length
                      ? const SizedBox.shrink()
                      : const Text('Đã hiển thị toàn bộ sách'),
            ),
          );
        },
      ),
    );
  }

  Widget _statusList({
    required String message,
    String? action,
    VoidCallback? onPressed,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return RefreshIndicator(
          onRefresh: () => _readBooks(refresh: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) => SizedBox(
              height: constraints.maxHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  EmptyView(message: message),
                  if (action != null)
                    TextButton(onPressed: onPressed, child: Text(action)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection({required this.books, required this.onBookTap});

  final List<Book> books;
  final ValueChanged<Book> onBookTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Sách nổi bật',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: books.length,
              itemBuilder: (BuildContext context, int index) {
                final Book book = books[index];
                return SizedBox(
                  width: 124,
                  child: BookCard(
                      book: book, compact: true, onTap: () => onBookTap(book)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
