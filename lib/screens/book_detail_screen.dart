import 'package:flutter/material.dart';

import '../models/book.dart';
import '../widgets/book_cover.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: 180,
                      height: 250,
                      child: BookCover(book: book),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(book.title,
                          style: Theme.of(context).textTheme.headlineSmall),
                      if (book.subtitle != null) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(book.subtitle!,
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                      if (book.authors.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text('Tác giả: ${book.authorNames}'),
                      ],
                      if (book.categories != null)
                        Text('Thể loại: ${book.categories}'),
                      if (book.publishedYear != null)
                        Text('Năm xuất bản: ${book.publishedYear}'),
                      if (book.numPages != null)
                        Text('Số trang: ${book.numPages}'),
                      if (book.isbn13.isNotEmpty)
                        Text('ISBN-13: ${book.isbn13}'),
                      if (book.isbn10.isNotEmpty)
                        Text('ISBN-10: ${book.isbn10}'),
                      if (book.averageRating != null)
                        Text('Đánh giá: ${book.averageRating}'
                            '${book.ratingsCount == null ? '' : ' (${book.ratingsCount} lượt)'}'),
                      if (book.description.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 20),
                        Text('Mô tả',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(book.description,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
