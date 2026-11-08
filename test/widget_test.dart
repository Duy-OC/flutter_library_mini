import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csv/csv.dart';

import 'package:flutter_library_mini/data/book_repository.dart';
import 'package:flutter_library_mini/main.dart';
import 'package:flutter_library_mini/screens/book_grid_screen.dart';
import 'package:flutter_library_mini/widgets/book_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String csvWithoutImages;
  setUpAll(() async {
    final source = await rootBundle.loadString(booksAssetPath);
    final rows = const CsvToListConverter(shouldParseNumbers: false, eol: '\n')
        .convert(source);
    for (final row in rows.skip(1)) {
      row[6] = '';
    }
    csvWithoutImages = const ListToCsvConverter().convert(rows);
  });

  testWidgets('chuyển tab lưới và mở chi tiết', (tester) async {
    expect(parseBooksCsv(csvWithoutImages), hasLength(200));
    final repository = BookRepository(loadCsv: () async => csvWithoutImages);
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.pump();
    await tester.tap(find.text('Lưới'));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('book-grid')), findsOneWidget);
    await tester.tap(find.byType(BookCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.textContaining('ISBN-13:'), findsOneWidget);
  });

  testWidgets('lưới thích ứng với cửa sổ hẹp và rộng', (tester) async {
    final repository = BookRepository(loadCsv: () async => csvWithoutImages);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester
        .pumpWidget(MaterialApp(home: BookGridScreen(repository: repository)));
    await tester.pump();
    final narrow = tester.widget<GridView>(find.byKey(const Key('book-grid')));
    expect(
        (narrow.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        1);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1200, 640);
    await tester.pump();
    final wide = tester.widget<GridView>(find.byKey(const Key('book-grid')));
    expect(
        (wide.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        6);
    expect(tester.takeException(), isNull);
  });
}
