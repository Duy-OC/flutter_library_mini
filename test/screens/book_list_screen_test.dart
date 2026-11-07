import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_library_mini/data/fake_books.dart';
import 'package:flutter_library_mini/screens/book_list_screen.dart';

Future<void> _pumpLoadedScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: BookListScreen()));
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

void main() {
  testWidgets('hiển thị loading, dải nổi bật và danh sách sách', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BookListScreen()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Sách nổi bật'), findsOneWidget);
    expect(find.byKey(const Key('book-search-field')), findsOneWidget);
    expect(find.text('Xem thêm'), findsWidgets);
    expect(find.text(allBooks.first.title), findsWidgets);
  });

  testWidgets('tìm kiếm không có kết quả hiển thị trạng thái rỗng', (
    WidgetTester tester,
  ) async {
    await _pumpLoadedScreen(tester);

    await tester.enterText(
      find.byKey(const Key('book-search-field')),
      'không-có-cuốn-sách-nào-như-thế',
    );
    await tester.pump();

    expect(find.text('Không tìm thấy sách'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('tìm kiếm theo tên lọc đúng sách', (
    WidgetTester tester,
  ) async {
    await _pumpLoadedScreen(tester);

    final String title = allBooks.first.title;
    await tester.enterText(
      find.byKey(const Key('book-search-field')),
      title,
    );
    await tester.pump();

    expect(find.text(title), findsWidgets);
    // Sách ngoài dải nổi bật không khớp từ khóa phải biến mất.
    expect(find.text(allBooks[10].title), findsNothing);
  });

  testWidgets('nút Xem thêm mở rộng và Thu gọn nội dung', (
    WidgetTester tester,
  ) async {
    await _pumpLoadedScreen(tester);

    expect(find.text('Thu gọn'), findsNothing);

    await tester.tap(find.text('Xem thêm').first);
    await tester.pump();

    expect(find.text('Thu gọn'), findsOneWidget);

    await tester.tap(find.text('Thu gọn'));
    await tester.pump();

    expect(find.text('Thu gọn'), findsNothing);
  });

  testWidgets('cuộn gần cuối sẽ tải thêm sách', (
    WidgetTester tester,
  ) async {
    await _pumpLoadedScreen(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.drag(
      find.byKey(const Key('book-list')),
      const Offset(0, -5000),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Có thể mất thêm một vài lần tải nếu vị trí cuộn vẫn còn sát cuối danh sách.
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
    }

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('bấm vào sách mở trang chi tiết', (
    WidgetTester tester,
  ) async {
    await _pumpLoadedScreen(tester);

    await tester.tap(find.text(allBooks.first.title).last);
    await tester.pumpAndSettle();

    expect(find.text('Tác giả: ${allBooks.first.author}'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
