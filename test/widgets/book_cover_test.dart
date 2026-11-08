import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_library_mini/models/book.dart';
import 'package:flutter_library_mini/widgets/book_cover.dart';

void main() {
  testWidgets('ảnh bìa lỗi hiện icon thay thế', (tester) async {
    final book = Book.fromCsvRecord(<String, String>{
      'title': 'Sách',
      'thumbnail': 'https://example.invalid/cover.jpg',
    });
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body:
              SizedBox(width: 100, height: 150, child: BookCover(book: book))),
    ));
    await tester.pump();
    expect(find.byIcon(Icons.menu_book), findsOneWidget);
  });
}
