import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_library_mini/data/fake_books.dart';
import 'package:flutter_library_mini/models/book.dart';

void main() {
  group('allBooks', () {
    test('sinh đúng 100 cuốn sách với id duy nhất', () {
      expect(allBooks, hasLength(totalFakeBooks));
      expect(allBooks, hasLength(100));

      final Set<int> ids = allBooks.map((Book book) => book.id).toSet();
      expect(ids, hasLength(allBooks.length));
    });

    test('mô tả có độ dài khác nhau và không rỗng', () {
      final Set<int> descriptionLengths =
          allBooks.map((Book book) => book.description.length).toSet();

      expect(descriptionLengths.length, greaterThan(1));
      expect(
        allBooks.every((Book book) => book.description.trim().isNotEmpty),
        isTrue,
      );
    });

    test('featuredBooks trả về 10 cuốn đầu tiên', () {
      expect(featuredBooks, hasLength(10));
      expect(
        featuredBooks.map((Book book) => book.id),
        allBooks.take(10).map((Book book) => book.id),
      );
    });
  });

  group('fetchBooks', () {
    test('trả về 20 cuốn đầu tiên ở trang 0', () async {
      final List<Book> books = await fetchBooks(0);

      expect(books, hasLength(20));
      expect(
        books.map((Book book) => book.id),
        allBooks.take(20).map((Book book) => book.id),
      );
    });

    test('trả về đúng dữ liệu của từng trang', () async {
      final List<Book> page1 = await fetchBooks(1);
      final List<Book> page4 = await fetchBooks(4);

      expect(page1, hasLength(20));
      expect(page1.first.id, allBooks[20].id);
      expect(page4, hasLength(20));
      expect(page4.last.id, allBooks[99].id);
    });

    test('trả về rỗng khi đã hết dữ liệu hoặc tham số không hợp lệ', () async {
      expect(await fetchBooks(5), isEmpty);
      expect(await fetchBooks(-1), isEmpty);
      expect(await fetchBooks(0, size: 0), isEmpty);
    });

    test('tôn trọng kích thước trang tùy chỉnh', () async {
      expect(await fetchBooks(0, size: 7), hasLength(7));
      expect(await fetchBooks(14, size: 7), hasLength(2));
      expect(await fetchBooks(15, size: 7), isEmpty);
    });
  });
}
