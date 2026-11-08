import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_library_mini/data/book_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('đọc 200 sách thật và giữ nguyên dữ liệu CSV', () async {
    final String csv = await rootBundle.loadString(booksAssetPath);
    final books = parseBooksCsv(csv);
    expect(books, hasLength(200));
    expect(books.first.isbn10, '0002005883');
    expect(books.first.title, 'Gilead');
    expect(books.first.description, contains('Gilead, Iowa'));
    expect(books.where((book) => book.averageRating == null), hasLength(2));
    expect(books.where((book) => book.numPages == null), hasLength(2));
    expect(books.where((book) => book.ratingsCount == null), hasLength(2));
    expect(
        books
            .firstWhere((book) => book.categories == 'Body, Mind & Spirit')
            .categories,
        'Body, Mind & Spirit');
  });

  test('parser xử lý BOM, dấu phẩy, nháy kép, xuống dòng và ô trống', () {
    const csv =
        '\uFEFFisbn13,isbn10,title,subtitle,authors,categories,thumbnail,description,published_year,average_rating,num_pages,ratings_count\n'
        '0123,0012,"Title, one",,A;B,"Body, Mind & Spirit",,"Line 1, ""quote""\nLine 2",,,,';
    final book = parseBooksCsv(csv).single;
    expect(book.isbn13, '0123');
    expect(book.isbn10, '0012');
    expect(book.title, 'Title, one');
    expect(book.authors, <String>['A', 'B']);
    expect(book.categories, 'Body, Mind & Spirit');
    expect(book.description, 'Line 1, "quote"\nLine 2');
    expect(book.averageRating, isNull);
    expect(book.numPages, isNull);
  });

  test('repository cache một lần và có thể đọc lại', () async {
    final csv = await rootBundle.loadString(booksAssetPath);
    int calls = 0;
    final repository = BookRepository(loadCsv: () async {
      calls++;
      return csv;
    });
    expect(await repository.loadBooks(), hasLength(200));
    expect(await repository.loadBooks(), hasLength(200));
    expect(calls, 1);
    await repository.refresh();
    expect(calls, 2);
  });

  test('lọc trên toàn bộ sách theo tên hoặc tác giả', () async {
    final books = parseBooksCsv(await rootBundle.loadString(booksAssetPath));
    final target = books[150];
    expect(searchBooks(books, target.title.toUpperCase()), contains(target));
    expect(searchBooks(books, books[150].authors.first.toUpperCase()),
        contains(target));
  });

  test('CSV lỗi báo FormatException', () {
    expect(() => parseBooksCsv('isbn13,title\n1,A'), throwsFormatException);
  });
}
