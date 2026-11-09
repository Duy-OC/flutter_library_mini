# Thư viện mini (Flutter Library Mini) — Chủ đề 5

Ứng dụng demo Flutter Material 3 minh họa chuyên sâu về **Danh sách, Lưới dữ liệu và Cuộn (ListView, GridView & Scrolling Techniques)**.

---

## 1. Tổng quan

Dự án **"Thư viện mini"** được phát triển nhằm minh họa và áp dụng các kỹ thuật quản lý và hiển thị danh sách dữ liệu trong Flutter:
- Minh họa các widget cuộn cốt lõi: `ListView`, `ListView.builder`, `GridView.builder`, `SingleChildScrollView`.
- Tối ưu hóa hiệu năng render danh sách lớn bằng cơ chế nạp widget theo nhu cầu (Lazy Building) và phân trang cuộn vô tận (Infinite Scroll / Lazy Loading).
- Thể hiện kỹ thuật cuộn lồng nhau (Nested Scrolling) với danh sách ngang đặt bên trong danh sách dọc.
- Xử lý các trạng thái giao diện thực tế: các phần tử có kích thước thay đổi linh hoạt (mô tả ngắn/dài, đóng/mở), tìm kiếm theo thời gian thực, trạng thái danh sách rỗng (Empty State), và cử chỉ kéo để làm mới (Pull-to-Refresh).
- Ứng dụng đọc dữ liệu cục bộ gồm 200 cuốn sách từ tệp CSV (`assets/data/books_200.csv`), không phụ thuộc backend ngoài, quản lý trạng thái tự nhiên thông qua `StatefulWidget` và `setState`.
- Đã được đóng gói sẵn file cài đặt APK tại thư mục `apk/app-release.apk`.

---

## 2. Tính năng chính

- **Danh sách sách cuộn mượt mà (`ListView.builder`):** Dựng widget theo nhu cầu, tiết kiệm bộ nhớ và đảm bảo 60fps kể cả khi danh sách có hàng trăm phần tử.
- **Dải "Sách nổi bật" cuộn ngang (Nested Horizontal Scroll):** Dải sách trượt ngang ở đầu trang được nhúng mượt mà trong danh sách cuộn dọc.
- **Tải lười / Cuộn vô tận (Lazy Loading):** Tự động phát hiện khi người dùng cuộn gần tới cuối trang (`ScrollController`) để nạp thêm từng đợt 20 cuốn sách kèm vòng xoay chờ tải trực quan.
- **Phần tử có chiều cao linh hoạt:** Mỗi thẻ sách trong danh sách dọc có thể mở rộng / thu gọn mô tả với nút "Xem thêm" / "Thu gọn", kích thước item co giãn tự nhiên.
- **Chế độ xem dạng lưới (`GridView.builder`):** Hiển thị trực quan sách dưới dạng lưới 2 cột với ảnh bìa sách và tên sách.
- **Tìm kiếm sách theo thời gian thực:** Lọc tức thời theo tên sách hoặc tên tác giả trên toàn bộ tập dữ liệu.
- **Xử lý trạng thái rỗng (`EmptyView`):** Giao diện thông báo thân thiện và nút bấm "Xóa tìm kiếm" khi không có dữ liệu phù hợp.
- **Kéo để làm mới (`RefreshIndicator`):** Cho phép kéo vuốt từ trên xuống để làm mới danh sách dữ liệu bất kỳ lúc nào.
- **Trang chi tiết sách (`SingleChildScrollView`):** Xem thông tin chi tiết một cuốn sách bao gồm ảnh bìa cỡ lớn, tác giả, thể loại, mã ISBN, số trang, năm xuất bản và toàn văn nội dung mô tả.

---

## 3. Công nghệ sử dụng

- **Framework:** [Flutter](https://flutter.dev/) (Channel stable, tương thích Flutter 3.x)
- **Ngôn ngữ:** [Dart](https://dart.dev/) (SDK `>=3.0.0 <4.0.0`)
- **Nguyên tắc thiết kế:** [Material 3 Design](https://m3.material.io/)
- **Thư viện phụ thuộc:**
  - [`csv: ^6.0.0`](https://pub.dev/packages/csv) — Phân tích cú pháp dữ liệu sách từ tệp CSV trong assets.
  - [`flutter_test`](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) — Bộ công cụ kiểm thử đơn vị và widget.
- **Quản lý trạng thái:** Quản lý state cục bộ với `StatefulWidget` và `setState` rõ ràng, tinh gọn, không lạm dụng các thư viện quản lý trạng thái phức tạp.
- **Kiến trúc mã nguồn:** Phân lớp rõ ràng theo cấu trúc Data (Repository) - Models - Screens - Widgets.

---

## 4. Hướng dẫn cài đặt

### Cách 1: Cài đặt trực tiếp bằng file APK (Khuyên dùng cho người dùng cuối)
File APK đã được biên dịch sẵn ở chế độ Release:
1. Tải file APK tại đường dẫn: [`apk/app-release.apk`](apk/app-release.apk)
2. Chép vào thiết bị Android và mở file để tiến hành cài đặt (cho phép cài đặt ứng dụng từ nguồn không xác định nếu được yêu cầu).
3. Hoặc cài đặt trực tiếp qua Android Debug Bridge (ADB):
   ```sh
   adb install apk/app-release.apk
   ```

### Cách 2: Chạy từ mã nguồn (Dành cho lập trình viên)

**Yêu cầu môi trường:**
- Đã cài đặt Flutter SDK (phiên bản `>= 3.0.0`)
- Đã cài đặt Dart SDK
- Thiết bị thật kết nối qua USB (bật USB Debugging) hoặc máy ảo Android Emulator

**Các bước thực hiện:**
1. Clone mã nguồn về máy:
   ```sh
   git clone <URL_REPOSITORY>
   cd flutter_library_mini
   ```

2. Cài đặt các thư viện phụ thuộc:
   ```sh
   flutter pub get
   ```

3. Kiểm tra chất lượng mã nguồn:
   ```sh
   dart format lib test
   flutter analyze
   flutter test
   ```

4. Chạy ứng dụng ở chế độ Debug:
   ```sh
   flutter run
   ```

5. (Tùy chọn) Biên dịch file APK Release:
   ```sh
   flutter build apk --release
   ```

---

## 5. Cách sử dụng

1. **Khám phá màn hình "Danh sách":**
   - Lướt xem dải **"Sách nổi bật"** cuộn ngang ở đầu danh sách.
   - Cuộn dọc để duyệt danh sách các cuốn sách.
   - Nhấn **"Xem thêm"** hoặc **"Thu gọn"** trên từng thẻ sách để xem hoặc ẩn bớt phần nội dung tóm tắt.
   - Khi cuộn gần tới cuối trang, ứng dụng sẽ tự động kích hoạt tải thêm 20 sách tiếp theo kèm chỉ báo tiến trình.
   - Kéo vuốt màn hình từ trên xuống để làm mới danh sách dữ liệu.
2. **Tìm kiếm sách:**
   - Nhập từ khóa (tên tác giả hoặc tên sách) vào ô tìm kiếm ở thanh trên cùng.
   - Danh sách sẽ lọc kết quả tức thì.
   - Nếu không có sách nào trùng khớp, màn hình trạng thái rỗng sẽ hiển thị kèm nút **"Xóa tìm kiếm"** để bạn dễ dàng hoàn tác.
3. **Chuyển sang màn hình "Lưới":**
   - Nhấn vào tab **"Lưới"** ở thanh điều hướng bên dưới (Bottom Navigation Bar).
   - Xem toàn bộ danh mục sách dưới dạng lưới 2 cột trực quan.
4. **Xem chi tiết cuốn sách:**
   - Chạm vào bất kỳ thẻ sách nào ở màn hình Danh sách hoặc Lưới.
   - Màn hình chi tiết hiển thị toàn bộ thông số: ảnh bìa lớn, tên sách, tác giả, thể loại, năm xuất bản, mã ISBN và nội dung mô tả đầy đủ hỗ trợ cuộn dọc.

---

## 6. Cấu trúc thư mục

```
flutter_library_mini/
├── android/                   # Cấu hình dự án nền tảng Android và Gradle
├── apk/                       # File APK release biên dịch sẵn
│   └── app-release.apk
├── assets/                    # Tài nguyên tĩnh của ứng dụng
│   └── data/
│       └── books_200.csv      # Tập dữ liệu 200 cuốn sách mẫu
├── lib/                       # Mã nguồn ứng dụng Flutter
│   ├── data/
│   │   └── book_repository.dart    # Nạp, xử lý và cache dữ liệu từ file CSV
│   ├── models/
│   │   └── book.dart               # Data model Book (đối tượng sách)
│   ├── screens/
│   │   ├── book_detail_screen.dart # Màn hình chi tiết sách (SingleChildScrollView)
│   │   ├── book_grid_screen.dart   # Màn hình hiển thị sách dạng lưới (GridView.builder)
│   │   ├── book_list_screen.dart   # Màn hình danh sách sách (ListView, Lazy loading, Search)
│   │   └── home_screen.dart        # Màn hình chính điều phối BottomNavigationBar
│   ├── widgets/
│   │   ├── book_card.dart          # Widget hiển thị thẻ sách dạng lưới / dải ngang
│   │   ├── book_cover.dart         # Widget hiển thị ảnh bìa kèm xử lý lỗi và placeholder
│   │   ├── book_tile.dart          # Widget hiển thị dòng sách với mô tả mở rộng linh hoạt
│   │   └── empty_view.dart         # Widget hiển thị trạng thái danh sách rỗng
│   └── main.dart                   # Entry point khởi chạy ứng dụng (MaterialApp)
├── slide/                     # Tài liệu thuyết trình và mã nguồn tạo slide Chủ đề 5
│   ├── assets/                # Hình ảnh minh họa dùng trong slide
│   ├── build_slides.py        # Kịch bản Python tạo slide
│   └── slidechude5.pdf        # Slide thuyết trình định dạng PDF
├── test/                      # Các bài kiểm thử Widget và Unit tests
│   └── widget_test.dart
├── pubspec.yaml               # Khai báo cấu hình dự án, assets và dependencies
└── README.md                  # Tài liệu hướng dẫn sử dụng và giới thiệu dự án
```

---

## 7. Giấy phép

Dự án được phân phối theo giấy phép [MIT License](LICENSE). Dự án phục vụ cho mục đích học tập, nghiên cứu và làm đồ án thực hành môn học Lập trình ứng dụng di động với Flutter.
