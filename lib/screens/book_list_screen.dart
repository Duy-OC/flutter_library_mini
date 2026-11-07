import 'package:flutter/material.dart';

import '../data/fake_books.dart';
import '../models/book.dart';

/// Màn hình danh sách sách.
///
/// Minh họa:
/// - `ListView.builder` cho danh sách dọc (chỉ build item đang hiển thị).
/// - Một `ListView` ngang lồng bên trong để làm dải "Sách nổi bật".
/// - Lazy loading bằng `ScrollController`.
/// - Item có chiều cao thay đổi nhờ mô tả dài/ngắn và nút "Xem thêm".
/// - Trạng thái rỗng khi tìm kiếm không có kết quả.
/// - Kéo xuống để làm mới bằng `RefreshIndicator`.
class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  static const int _pageSize = 20;

  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<Book> _books = <Book>[];

  int _page = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) {
      return;
    }

    final ScrollPosition position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) {
      return;
    }

    setState(() => _isLoading = true);

    final List<Book> newBooks = await fetchBooks(_page, size: _pageSize);
    if (!mounted) {
      return;
    }

    setState(() {
      _books.addAll(newBooks);
      _page++;
      _hasMore = newBooks.isNotEmpty;
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _books.clear();
      _page = 0;
      _hasMore = true;
      _isLoading = false;
    });
    await _loadMore();
  }

  List<Book> get _shownBooks {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return _books;
    }
    return _books
        .where((Book book) => book.title.toLowerCase().contains(query))
        .toList(growable: false);
  }

  void _openDetail(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _BookDetailPage(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Book> shown = _shownBooks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện mini'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              key: const Key('book-search-field'),
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (String value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên sách',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xóa tìm kiếm',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _buildContent(shown),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Book> shown) {
    if (_books.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (shown.isEmpty) {
      return const _EmptyView(message: 'Không tìm thấy sách');
    }

    return ListView.builder(
      key: const Key('book-list'),
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 1 + shown.length + (_isLoading ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _FeaturedSection(onBookTap: _openDetail);
        }

        final int bookIndex = index - 1;
        if (bookIndex < shown.length) {
          final Book book = shown[bookIndex];
          return _BookTile(
            book: book,
            onTap: () => _openDetail(book),
          );
        }

        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

/// Dải sách nổi bật: danh sách ngang nằm trong danh sách dọc.
class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection({required this.onBookTap});

  final ValueChanged<Book> onBookTap;

  @override
  Widget build(BuildContext context) {
    final List<Book> books = featuredBooks;

    return SizedBox(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Sách nổi bật',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: books.length,
              itemBuilder: (BuildContext context, int index) {
                final Book book = books[index];
                return _FeaturedBookCard(
                  book: book,
                  onTap: () => onBookTap(book),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBookCard extends StatelessWidget {
  const _FeaturedBookCard({required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 116,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: book.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.menu_book, color: Colors.white, size: 36),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item dạng danh sách có chiều cao thay đổi.
class _BookTile extends StatefulWidget {
  const _BookTile({required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  State<_BookTile> createState() => _BookTileState();
}

class _BookTileState extends State<_BookTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final Book book = widget.book;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 56,
                height: 76,
                decoration: BoxDecoration(
                  color: book.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.author} • ${book.category}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.description,
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _expanded = !_expanded),
                        child: Text(_expanded ? 'Thu gọn' : 'Xem thêm'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trạng thái rỗng khi tìm kiếm không có kết quả.
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.menu_book,
            size: 72,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Trang chi tiết tối giản, dùng `SingleChildScrollView` cho nội dung ít.
class _BookDetailPage extends StatelessWidget {
  const _BookDetailPage({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 250,
              color: book.color,
              child: const Center(
                child: Icon(Icons.menu_book, color: Colors.white, size: 96),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Tác giả: ${book.author}'),
                  const SizedBox(height: 4),
                  Text('Thể loại: ${book.category}'),
                  const SizedBox(height: 16),
                  Text(
                    book.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
