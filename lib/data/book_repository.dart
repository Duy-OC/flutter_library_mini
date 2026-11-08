import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../models/book.dart';

const String booksAssetPath = 'assets/data/books_200.csv';

class BookRepository {
  BookRepository({Future<String> Function()? loadCsv})
      : _loadCsv = loadCsv ?? (() => rootBundle.loadString(booksAssetPath));

  final Future<String> Function() _loadCsv;
  Future<List<Book>>? _cachedBooks;

  Future<List<Book>> loadBooks() {
    final Future<List<Book>>? cached = _cachedBooks;
    if (cached != null) return cached;
    final Future<List<Book>> future = Future<String>.sync(_loadCsv)
        .then((String source) => parseBooksCsv(source));
    _cachedBooks = future;
    future.then<void>((_) {}, onError: (Object error, StackTrace trace) {
      if (identical(_cachedBooks, future)) _cachedBooks = null;
    });
    return future;
  }

  Future<List<Book>> refresh() {
    _cachedBooks = null;
    return loadBooks();
  }
}

final BookRepository bookRepository = BookRepository();

const List<String> _requiredColumns = <String>[
  'isbn13',
  'isbn10',
  'title',
  'subtitle',
  'authors',
  'categories',
  'thumbnail',
  'description',
  'published_year',
  'average_rating',
  'num_pages',
  'ratings_count',
];

List<Book> parseBooksCsv(String source) {
  final String csv = source.startsWith('\uFEFF') ? source.substring(1) : source;
  final int headerEnd = csv.indexOf('\n');
  final String eol =
      headerEnd > 0 && csv[headerEnd - 1] == '\r' ? '\r\n' : '\n';
  final List<List<dynamic>> rows = CsvToListConverter(
    shouldParseNumbers: false,
    eol: eol,
  ).convert(csv);
  if (rows.isEmpty) throw const FormatException('CSV không có hàng tiêu đề.');

  final List<String> headers = rows.first
      .map((dynamic cell) => cell.toString().trim().replaceFirst('\uFEFF', ''))
      .toList(growable: false);
  for (final String column in _requiredColumns) {
    if (!headers.contains(column)) {
      throw FormatException('CSV thiếu cột $column.');
    }
  }

  final List<Book> books = <Book>[];
  for (int index = 1; index < rows.length; index++) {
    final List<dynamic> cells = rows[index];
    if (cells.every((dynamic cell) => cell.toString().trim().isEmpty)) continue;
    if (cells.length != headers.length) {
      throw FormatException('CSV sai số cột ở bản ghi $index.');
    }
    final Map<String, String> record = <String, String>{
      for (int column = 0; column < headers.length; column++)
        headers[column]: cells[column].toString(),
    };
    books.add(Book.fromCsvRecord(record));
  }
  return List<Book>.unmodifiable(books);
}

List<Book> searchBooks(List<Book> books, String query) {
  final String normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return books;
  return books.where((Book book) {
    return book.title.toLowerCase().contains(normalized) ||
        book.authors
            .any((String author) => author.toLowerCase().contains(normalized));
  }).toList(growable: false);
}
