# Thư viện mini — Chủ đề 5

Ứng dụng Flutter Material 3 minh họa danh sách, lưới dữ liệu và cuộn. Giao diện bằng tiếng Việt; tên sách, tác giả, thể loại và mô tả giữ nguyên từ CSV. Không dùng backend hoặc thư viện quản lý trạng thái.

## Dữ liệu và chạy ứng dụng

Dữ liệu nằm tại `assets/data/books_200.csv` (200 sách). `BookRepository` đọc bằng `rootBundle`, dùng thư viện `csv` và cache kết quả. ISBN được giữ dạng chuỗi; số liệu trống được bỏ qua khi hiển thị. Ảnh bìa lấy từ URL trong CSV, nên cần Internet; ảnh lỗi hiện icon thay thế. Ứng dụng chưa lưu ảnh offline, và không bảo đảm mọi URL còn hoạt động.

```sh
flutter pub get
flutter run
```

Kiểm tra:

```sh
dart format lib test
flutter analyze
flutter test
```

## Kịch bản demo

1. Mở tab **Danh sách**: xem dải nổi bật cuộn ngang trong danh sách dọc, đọc dòng “Đã hiển thị 20/200 sách”.
2. Cuộn gần cuối để thấy vòng tải và thêm 20 sách; mở rộng và thu gọn mô tả của một sách.
3. Tìm tên hoặc tác giả của sách ở gần cuối CSV: kết quả vẫn xuất hiện. Tìm từ khóa không tồn tại rồi dùng **Xóa tìm kiếm**.
4. Kéo xuống để làm mới, kể cả khi danh sách kết quả ngắn hoặc rỗng.
5. Chuyển sang tab **Lưới**, cuộn và mở một sách để xem ảnh bìa, thông tin và mô tả đầy đủ.

`ListView.builder` và `GridView.builder` chỉ dựng widget khi cần để tiết kiệm chi phí giao diện. Việc này khác với phân trang: toàn bộ 200 bản ghi CSV được đọc vào bộ nhớ một lần, còn danh sách dọc chỉ **hiển thị thêm** 20 sách sau mỗi lần cuộn gần cuối. Độ trễ 350 ms khi hiện trang tiếp theo chỉ là mô phỏng, không có lệnh gọi API.
