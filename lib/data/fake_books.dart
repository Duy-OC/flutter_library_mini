import 'dart:math';

import 'package:flutter/material.dart';

import '../models/book.dart';

/// Số cuốn sách giả lập có sẵn trong "thư viện".
const int totalFakeBooks = 100;

const int _pageSize = 20;

const List<String> bookCategories = <String>[
  'Văn học',
  'Khoa học',
  'Thiếu nhi',
  'Lịch sử',
  'Kỹ năng',
];

const List<String> _titles = <String>[
  'Dế Mèn Phiêu Lưu Ký',
  'Số Đỏ',
  'Tắt Đèn',
  'Chí Phèo',
  'Lão Hạc',
  'Mắt Biếc',
  'Rừng Na Uy',
  'Nhà Giả Kim',
  'Hoàng Tử Bé',
  'Tuổi Thơ Dữ Dội',
  'Không Gia Đình',
  'Hai Số Phận',
  'Đắc Nhân Tâm',
  'Sapiens: Lược Sử Loài Người',
  'Vũ Trụ Trong Vỏ Hạt Dẻ',
];

const List<String> _authors = <String>[
  'Tô Hoài',
  'Vũ Trọng Phụng',
  'Ngô Tất Tố',
  'Nam Cao',
  'Nguyễn Nhật Ánh',
  'Haruki Murakami',
  'Paulo Coelho',
  'Antoine de Saint-Exupéry',
  'Phùng Quán',
  'Hector Malot',
  'Dale Carnegie',
  'Yuval Noah Harari',
  'Stephen Hawking',
];

const List<String> _sentences = <String>[
  'Cuốn sách mở ra một thế giới giàu cảm xúc và nhiều suy ngẫm.',
  'Tác phẩm kể về hành trình trưởng thành của những con người bình dị.',
  'Những trang viết nhẹ nhàng nhưng để lại dư âm sâu sắc trong lòng người đọc.',
  'Câu chuyện được dẫn dắt khéo léo qua nhiều tình huống bất ngờ.',
  'Tác giả khắc họa nhân vật với những nét tính cách rất đời thường.',
  'Cuốn sách phù hợp để đọc chậm, suy ngẫm và ghi lại những điều tâm đắc.',
  'Mỗi chương là một lát cắt sinh động về cuộc sống và con người.',
  'Thông điệp của tác phẩm vượt qua thời gian và vẫn còn nguyên giá trị.',
];

/// Sinh sẵn 100 cuốn sách với mô tả dài ngắn khác nhau.
///
/// Dùng [Random] có seed cố định để dữ liệu ổn định giữa các lần chạy,
/// nhờ đó demo và test đều cho kết quả nhất quán.
final List<Book> allBooks = _generateBooks();

/// Danh sách sách dùng cho dải "Sách nổi bật" cuộn ngang.
List<Book> get featuredBooks => allBooks.take(10).toList(growable: false);

List<Book> _generateBooks() {
  final Random random = Random(2026);

  return List<Book>.generate(totalFakeBooks, (int index) {
    final int sentenceCount = 1 + random.nextInt(5);
    final String description = List<String>.generate(
      sentenceCount,
      (_) => _sentences[random.nextInt(_sentences.length)],
    ).join(' ');

    return Book(
      id: index + 1,
      title: _buildTitle(index),
      author: _authors[random.nextInt(_authors.length)],
      category: bookCategories[index % bookCategories.length],
      description: description,
      color: Colors.primaries[index % Colors.primaries.length],
    );
  }, growable: false);
}

String _buildTitle(int index) {
  final String baseTitle = _titles[index % _titles.length];
  final int volume = index ~/ _titles.length + 1;
  return volume == 1 ? baseTitle : '$baseTitle - Tập $volume';
}

/// Giả lập việc tải dữ liệu từ mạng.
///
/// Trả về tối đa [size] cuốn sách của trang [page] (trang bắt đầu từ 0).
/// Sau 1 giây, nếu đã hết dữ liệu thì trả về danh sách rỗng.
Future<List<Book>> fetchBooks(int page, {int size = _pageSize}) async {
  await Future<void>.delayed(const Duration(seconds: 1));

  if (page < 0 || size <= 0) {
    return <Book>[];
  }

  final int start = page * size;
  if (start >= allBooks.length) {
    return <Book>[];
  }

  return allBooks.skip(start).take(size).toList(growable: false);
}
