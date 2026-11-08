import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_library_mini/data/book_repository.dart';
import 'package:flutter_library_mini/screens/book_list_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String csv;
  setUpAll(() async => csv = await rootBundle.loadString(booksAssetPath));

  Future<void> openList(WidgetTester tester,
      {BookRepository? repository}) async {
    await tester.pumpWidget(MaterialApp(
      home: BookListScreen(
          repository: repository ?? BookRepository(loadCsv: () async => csv)),
    ));
    await tester.pump();
  }

  testWidgets('hiển thị 20/200, sách nổi bật và mô tả mở rộng', (tester) async {
    await openList(tester);
    expect(find.text('Đã hiển thị 20/200 sách'), findsOneWidget);
    expect(find.text('Sách nổi bật'), findsOneWidget);
    await tester.tap(find.text('Xem thêm').first);
    await tester.pump();
    expect(find.text('Thu gọn'), findsOneWidget);
  });

  testWidgets('tìm sách ngoài 20 đầu và ẩn sách nổi bật', (tester) async {
    await openList(tester);
    final target = parseBooksCsv(csv)[150];
    await tester.enterText(
        find.byKey(const Key('book-search-field')), target.title);
    await tester.pump();
    expect(find.text(target.title), findsWidgets);
    expect(find.text('Sách nổi bật'), findsNothing);
    expect(find.textContaining('Đã hiển thị 1/'), findsWidgets);
  });

  testWidgets('phân trang trên kết quả đã lọc', (tester) async {
    await openList(tester);
    final int total = searchBooks(parseBooksCsv(csv), 'a').length;
    expect(total, greaterThan(20));
    await tester.enterText(find.byKey(const Key('book-search-field')), 'a');
    await tester.pump();
    expect(find.text('Đã hiển thị 20/$total sách'), findsOneWidget);
    await tester.drag(
        find.byKey(const Key('book-list')), const Offset(0, -6000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Đã hiển thị 40/$total sách'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('đổi từ khóa khi đang tải không nhận trang cũ', (tester) async {
    await openList(tester);
    await tester.enterText(find.byKey(const Key('book-search-field')), 'a');
    await tester.pump();
    await tester.drag(
        find.byKey(const Key('book-list')), const Offset(0, -6000));
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('book-search-field')), 'Gilead');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Đã hiển thị 1/1 sách'), findsOneWidget);
    expect(find.text('Sách nổi bật'), findsNothing);
  });

  testWidgets('không có kết quả có nút xóa và vẫn kéo làm mới được',
      (tester) async {
    await openList(tester);
    await tester.enterText(
        find.byKey(const Key('book-search-field')), 'zzz-no-book');
    await tester.pump();
    expect(find.text('Không tìm thấy sách'), findsOneWidget);
    expect(find.text('Xóa tìm kiếm'), findsWidgets);
    await tester.drag(find.byType(ListView).first, const Offset(0, 400));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Xóa tìm kiếm').last);
    await tester.pump();
    expect(find.text('Đã hiển thị 20/200 sách'), findsOneWidget);
  });

  testWidgets('lỗi CSV có nút thử lại', (tester) async {
    int calls = 0;
    final repository = BookRepository(loadCsv: () async {
      calls++;
      if (calls == 1) throw const FormatException('bad csv');
      return csv;
    });
    await openList(tester, repository: repository);
    expect(find.text('Không đọc được dữ liệu sách.'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Đã hiển thị 20/200 sách'), findsOneWidget);
  });
}
