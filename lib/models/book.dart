import 'package:flutter/material.dart';

/// Một cuốn sách hiển thị trong ứng dụng.
///
/// Ứng dụng không dùng database hay API nên toàn bộ dữ liệu của sách
/// được sinh giả lập trong [Book] và tầng data.
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.color,
  });

  final int id;
  final String title;
  final String author;

  /// Văn học, Khoa học, Thiếu nhi...
  final String category;

  /// Độ dài ngẫu nhiên để tile trong danh sách có chiều cao khác nhau.
  final String description;

  /// Màu bìa thay cho ảnh.
  final Color color;

  @override
  String toString() => 'Book(id: $id, title: $title)';
}
