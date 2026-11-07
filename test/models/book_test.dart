import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_library_mini/models/book.dart';

void main() {
  test('Book lưu đầy đủ thông tin', () {
    const Book book = Book(
      id: 7,
      title: 'Tên sách',
      author: 'Tác giả',
      category: 'Văn học',
      description: 'Mô tả',
      color: Colors.blue,
    );

    expect(book.id, 7);
    expect(book.title, 'Tên sách');
    expect(book.author, 'Tác giả');
    expect(book.category, 'Văn học');
    expect(book.description, 'Mô tả');
    expect(book.color, Colors.blue);
  });
}
