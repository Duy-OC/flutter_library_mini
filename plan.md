# Plan – Ứng dụng "Thư viện mini" (Flutter)

**Chủ đề 5:** Danh sách, lưới dữ liệu và cuộn

## 1. Mục tiêu
App hiển thị danh sách sách. Qua app minh họa được:
- `ListView`, `ListView.builder`, `GridView`, `SingleChildScrollView`
- Cuộn lồng nhau (danh sách ngang nằm trong danh sách dọc)
- Lazy loading: cuộn tới cuối thì tải thêm
- Phần tử có kích thước khác nhau (tên sách / mô tả dài ngắn khác nhau)
- Trạng thái danh sách rỗng (tìm kiếm không có kết quả)

Không dùng database, không gọi API, không dùng thư viện quản lý state. Dữ liệu giả sinh trong code, quản lý bằng `setState`.

## 2. Cấu trúc thư mục
```
lib/
├── main.dart                  # MaterialApp + HomeScreen
├── models/
│   └── book.dart              # class Book
├── data/
│   └── fake_books.dart        # Sinh dữ liệu giả + hàm fetchBooks(page)
├── screens/
│   ├── home_screen.dart       # BottomNavigationBar: Danh sách / Lưới
│   ├── book_list_screen.dart  # ListView.builder + lazy loading + tìm kiếm + rỗng
│   ├── book_grid_screen.dart  # GridView.builder
│   └── book_detail_screen.dart# SingleChildScrollView
└── widgets/
    ├── book_tile.dart         # Item dạng danh sách (chiều cao thay đổi)
    ├── book_card.dart         # Item dạng lưới
    └── empty_view.dart        # Giao diện khi không có dữ liệu
```

## 3. Model
```dart
class Book {
  final int id;
  final String title;
  final String author;
  final String category;   // Văn học, Khoa học, Thiếu nhi...
  final String description; // độ dài ngẫu nhiên → item cao thấp khác nhau
  final Color color;        // màu bìa thay cho ảnh
}
```

`fake_books.dart`:
- Sinh sẵn 100 cuốn sách bằng `List.generate`, mỗi cuốn có mô tả lặp ngẫu nhiên 1–5 câu.
- `Future<List<Book>> fetchBooks(int page, {int size = 20})`: `await Future.delayed(1s)` rồi trả về 20 cuốn tiếp theo (giả lập tải mạng).

## 4. Đặc tả chức năng

| # | Màn hình | Chức năng | Kiến thức minh họa |
|---|----------|-----------|--------------------|
| 1 | Home | 2 tab: Danh sách / Lưới | Điều hướng cơ bản |
| 2 | Danh sách | Phía trên: dải "Sách nổi bật" cuộn ngang | Cuộn lồng nhau (ListView ngang trong ListView dọc) |
| 3 | Danh sách | Danh sách sách bên dưới, tạo item theo nhu cầu | `ListView.builder` |
| 4 | Danh sách | Cuộn gần cuối → tải thêm 20 cuốn, hiện vòng xoay ở cuối; hết dữ liệu thì dừng | Lazy loading, `ScrollController` |
| 5 | Danh sách | Mỗi item có mô tả độ dài khác nhau; bấm "Xem thêm" để mở rộng/thu gọn | Phần tử kích thước khác nhau |
| 6 | Danh sách | Ô tìm kiếm theo tên; không có kết quả → hiện `EmptyView` | Trạng thái rỗng |
| 7 | Danh sách | Kéo xuống để làm mới | `RefreshIndicator` |
| 8 | Lưới | Hiển thị sách dạng lưới 2 cột, bìa màu + tên | `GridView.builder` |
| 9 | Chi tiết | Bấm vào sách → bìa lớn, thông tin, mô tả dài | `SingleChildScrollView` |

## 5. Hướng triển khai

### 5.1 Cuộn lồng nhau (book_list_screen)
Dùng một `ListView.builder` dọc duy nhất. Phần tử index 0 là dải nổi bật:
```dart
SizedBox(
  height: 160,                    // bắt buộc cố định chiều cao
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: featured.length,
    itemBuilder: (_, i) => BookCard(book: featured[i]),
  ),
)
```
Ghi chú hiệu năng: tránh `ListView(shrinkWrap: true)` lồng trong `Column`/`SingleChildScrollView` với dữ liệu dài, vì `shrinkWrap` build toàn bộ item và mất lazy loading.

### 5.2 Lazy loading
```dart
_controller.addListener(() {
  if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200 &&
      !_isLoading && _hasMore) {
    _loadMore();
  }
});

Future<void> _loadMore() async {
  setState(() => _isLoading = true);
  final newBooks = await fetchBooks(_page);
  setState(() {
    _books.addAll(newBooks);
    _page++;
    _hasMore = newBooks.isNotEmpty;
    _isLoading = false;
  });
}
```
`itemCount = 1 (dải nổi bật) + books.length + (isLoading ? 1 : 0)` → item cuối là `CircularProgressIndicator`.

### 5.3 Phần tử kích thước khác nhau (book_tile)
- `StatefulWidget` có biến `expanded`.
- `Text(description, maxLines: expanded ? null : 2, overflow: TextOverflow.ellipsis)` + nút "Xem thêm / Thu gọn".
- Không đặt `itemExtent` để ListView tự tính chiều cao từng item.

### 5.4 Trạng thái rỗng
```dart
final shown = _books.where((b) =>
    b.title.toLowerCase().contains(_query.toLowerCase())).toList();
if (shown.isEmpty) return const EmptyView(message: 'Không tìm thấy sách');
```
`EmptyView`: `Center` + `Icon(Icons.menu_book)` + `Text`.

### 5.5 Lưới (book_grid_screen)
```dart
GridView.builder(
  padding: const EdgeInsets.all(8),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.7,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: allBooks.length,
  itemBuilder: (_, i) => BookCard(book: allBooks[i]),
)
```
Lưới ô có kích thước cố định nên tên dài được cắt bằng `maxLines: 2` (đối lập với ListView ở 5.3).

### 5.6 Chi tiết (book_detail_screen)
`SingleChildScrollView` bọc `Column`: bìa (Container màu, cao 250) → tên, tác giả, thể loại → mô tả dài. Dùng được ở đây vì nội dung ít và cố định; không dùng cho danh sách dài vì nó build toàn bộ con cùng lúc.

## 6. Kế hoạch thực hiện
1. Tạo project, model `Book`, dữ liệu giả.
2. `HomeScreen` + 2 tab.
3. `BookListScreen` với `ListView.builder` + `BookTile`.
4. Thêm lazy loading + refresh.
5. Thêm tìm kiếm + `EmptyView`.
6. Thêm dải nổi bật cuộn ngang (cuộn lồng nhau).
7. `BookGridScreen` + `BookCard`.
8. `BookDetailScreen`.
9. Chạy thử, chuẩn bị demo.

## 7. Kịch bản demo (~3 phút)
1. Mở app → cuộn ngang dải nổi bật, cuộn dọc danh sách.
2. Cuộn xuống cuối → thấy vòng xoay, tải thêm 20 cuốn.
3. Bấm "Xem thêm" trên vài item → chiều cao item thay đổi.
4. Gõ từ khóa không tồn tại → màn hình rỗng.
5. Chuyển sang tab Lưới.
6. Bấm một cuốn → trang chi tiết cuộn bằng `SingleChildScrollView`.
7. Giải thích ngắn: `builder` chỉ tạo item đang hiển thị, `shrinkWrap` / `SingleChildScrollView` không phù hợp với dữ liệu dài.
