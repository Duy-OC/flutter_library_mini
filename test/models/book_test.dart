import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_library_mini/models/book.dart';

void main() {
  test('Book chuyển bản ghi CSV, giữ ISBN dạng chuỗi và URL bìa https', () {
    final book = Book.fromCsvRecord(<String, String>{
      'isbn13': '000123',
      'isbn10': '0012',
      'title': 'Tên sách',
      'subtitle': '',
      'authors': 'Tác giả A; Tác giả B',
      'categories': 'Body, Mind & Spirit',
      'thumbnail': 'http://books.google.com/books/content?id=1',
      'description': 'Mô tả',
      'published_year': '2020',
      'average_rating': '',
      'num_pages': 'abc',
      'ratings_count': '',
    });
    expect(book.isbn13, '000123');
    expect(book.authors, <String>['Tác giả A', 'Tác giả B']);
    expect(book.categories, 'Body, Mind & Spirit');
    expect(book.coverUrl, startsWith('https://books.google.com/'));
    expect(book.publishedYear, 2020);
    expect(book.averageRating, isNull);
    expect(book.numPages, isNull);
    expect(book.subtitle, isNull);
  });
}
