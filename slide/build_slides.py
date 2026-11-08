#!/usr/bin/env python3
"""Sinh slide 'Chủ đề 5. Danh sách, lưới dữ liệu và cuộn' theo phong cách sample.pdf.

Chạy:  python3 build_slides.py   ->  slide_chu_de_5.pptx
Cần:   pip install python-pptx pygments pillow
"""
import os
from PIL import Image
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.util import Inches, Pt, Emu
from pygments.lexers import DartLexer
from pygments.token import Token

HERE = os.path.dirname(os.path.abspath(__file__))
A = os.path.join(HERE, "assets")

NAVY = RGBColor(0x00, 0x00, 0x50)
GOLD = RGBColor(0xFF, 0xC0, 0x00)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)
BLACK = RGBColor(0x11, 0x11, 0x11)
GRAY = RGBColor(0x6B, 0x6B, 0x6B)
RED = RGBColor(0xC0, 0x1F, 0x1F)
BLUE = RGBColor(0x1F, 0x3F, 0xB0)
PANEL = RGBColor(0xF5, 0xF6, 0xFA)
FONT = "Calibri"
MONO = "Courier New"

W, H = 13.333, 7.5
prs = Presentation()
prs.slide_width, prs.slide_height = Inches(W), Inches(H)
BLANK = prs.slide_layouts[6]
page = [0]


# ---------------------------------------------------------------- helpers
def poly(slide, pts, fill, line=None, lw=1.5, sx=W / 693, sy=H / 390):
    """Vẽ đa giác; pts theo hệ toạ độ 693x390 của ảnh mẫu."""
    fb = slide.shapes.build_freeform(Inches(pts[0][0] * sx), Inches(pts[0][1] * sy))
    fb.add_line_segments([(Inches(x * sx), Inches(y * sy)) for x, y in pts[1:]], close=True)
    s = fb.convert_to_shape()
    s.fill.solid(); s.fill.fore_color.rgb = fill
    if line is None:
        s.line.fill.background()
    else:
        s.line.color.rgb = line; s.line.width = Pt(lw)
    s.shadow.inherit = False
    return s


def rect(slide, x, y, w, h, fill, line=None):
    s = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(x), Inches(y), Inches(w), Inches(h))
    s.fill.solid(); s.fill.fore_color.rgb = fill
    if line is None:
        s.line.fill.background()
    else:
        s.line.color.rgb = line
    s.shadow.inherit = False
    return s


def text(slide, x, y, w, h, s, size=20, bold=False, color=BLACK, align=PP_ALIGN.LEFT,
         anchor=MSO_ANCHOR.TOP, italic=False, font=FONT):
    tb = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = tb.text_frame; tf.word_wrap = True; tf.vertical_anchor = anchor
    tf.margin_left = tf.margin_right = Inches(0.05)
    lines = s.split("\n")
    for i, ln in enumerate(lines):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.alignment = align
        r = p.add_run(); r.text = ln
        f = r.font; f.size = Pt(size); f.bold = bold; f.italic = italic
        f.color.rgb = color; f.name = font
    return tb


def bullets(slide, x, y, w, h, items, size=19, gap=8):
    """items: str | (str, level) ; '**' đầu chuỗi => in đậm phần trước dấu ':'."""
    tb = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = tb.text_frame; tf.word_wrap = True
    first = True
    for it in items:
        lvl = 0
        if isinstance(it, tuple):
            it, lvl = it
        p = tf.paragraphs[0] if first else tf.add_paragraph()
        first = False
        p.space_after = Pt(gap)
        mark = "▪ " if lvl == 0 else "– "
        pre = Pt(0)
        r = p.add_run(); r.text = ("    " * lvl) + mark
        r.font.size = Pt(size - 2 * lvl); r.font.color.rgb = NAVY if lvl == 0 else GRAY
        r.font.name = FONT
        import re
        for seg in re.split(r"(\*\*.+?\*\*|`.+?`)", it):
            if not seg:
                continue
            r = p.add_run(); r.font.size = Pt(size - 2 * lvl)
            if seg.startswith("**"):
                r.text = seg[2:-2]; r.font.bold = True; r.font.color.rgb = NAVY; r.font.name = FONT
            elif seg.startswith("`"):
                r.text = seg[1:-1]; r.font.name = MONO; r.font.color.rgb = RED
                r.font.size = Pt(size - 2 * lvl - 1)
            else:
                r.text = seg; r.font.color.rgb = BLACK; r.font.name = FONT
    return tb


def picture_fit(slide, path, x, y, w, h):
    iw, ih = Image.open(path).size
    sc = min(w / iw, h / ih)
    pw, ph = iw * sc, ih * sc
    return slide.shapes.add_picture(path, Inches(x + (w - pw) / 2), Inches(y + (h - ph) / 2),
                                    Inches(pw), Inches(ph))


TAG = [""]


def frame(title):
    """Slide nội dung: logo khoa (trái), thanh tiêu đề navy, số trang vàng."""
    s = prs.slides.add_slide(BLANK)
    page[0] += 1
    rect(s, 0, 0, W, H, WHITE)
    rect(s, 2.55, 0, W - 2.55, 0.95, NAVY)
    s.shapes.add_picture(os.path.join(A, "logo_khoa.png"), Inches(0.25), Inches(0.12), height=Inches(0.72))
    if TAG[0]:
        text(s, 2.7, 0.04, W - 2.7 - 1.3, 0.3, TAG[0], size=12, bold=True, color=GOLD, align=PP_ALIGN.CENTER)
    text(s, 2.7, 0.2, W - 2.7 - 1.3, 0.75, title, size=26, bold=True, color=WHITE,
         align=PP_ALIGN.CENTER, anchor=MSO_ANCHOR.MIDDLE)
    text(s, W - 1.2, 0, 1.0, 0.95, str(page[0] + 1), size=26, bold=True, color=GOLD,
         align=PP_ALIGN.RIGHT, anchor=MSO_ANCHOR.MIDDLE)
    return s


def source(slide, s):
    text(slide, 0.5, H - 0.42, W - 1.0, 0.32, "Nguồn: " + s, size=11, color=GRAY, italic=True)


def code_box(slide, x, y, w, h, code, size=12):
    rect(slide, x, y, w, h, PANEL, line=RGBColor(0xD5, 0xD8, 0xE6))
    tb = slide.shapes.add_textbox(Inches(x + 0.05), Inches(y + 0.05), Inches(w - 0.1), Inches(h - 0.1))
    tf = tb.text_frame; tf.word_wrap = False
    tokens = list(DartLexer().get_tokens(code.strip("\n")))
    # gom theo dòng
    lines, cur = [], []
    for tt, val in tokens:
        parts = val.split("\n")
        for i, part in enumerate(parts):
            if i > 0:
                lines.append(cur); cur = []
            if part:
                cur.append((tt, part))
    lines.append(cur)
    if lines and not lines[-1]:
        lines.pop()
    for n, ln in enumerate(lines):
        p = tf.paragraphs[0] if n == 0 else tf.add_paragraph()
        p.space_after = Pt(0)
        r = p.add_run(); r.text = f"{n + 1:>2}  "
        r.font.size = Pt(size - 2); r.font.color.rgb = RGBColor(0xA0, 0xA0, 0xA0); r.font.name = MONO
        for tt, val in ln:
            r = p.add_run(); r.text = val
            f = r.font; f.size = Pt(size); f.name = MONO; f.color.rgb = BLACK
            if tt in Token.Comment:
                f.color.rgb = GRAY; f.italic = True
            elif tt in Token.Literal.String:
                f.color.rgb = RED
            elif tt in Token.Literal.Number:
                f.color.rgb = BLUE
            elif tt in Token.Keyword:
                f.bold = True; f.color.rgb = NAVY
            elif tt in Token.Name.Class or tt in Token.Name.Builtin:
                f.color.rgb = RGBColor(0x00, 0x6B, 0x6B)


def code_slide(title, code, head, items, size=12, split=7.7, src=None, txt_size=17, pics=None):
    s = frame(title)
    lines_ = code.strip("\n").split("\n")
    n = len(lines_)
    L = max(len(l) for l in lines_) + 6
    size = min(16, (split * 72 - 14) / (0.62 * L), 5.1 * 72 / (1.3 * n))
    h = min(5.5, max(2.5, n * size * 1.3 / 72 + 0.35))
    code_box(s, 0.4, 1.3, split, h, code, size)
    # đường kẻ dọc như sample
    ln = s.shapes.add_connector(1, Inches(0.4 + split + 0.2), Inches(1.3), Inches(0.4 + split + 0.2), Inches(6.7))
    ln.line.color.rgb = BLACK; ln.line.width = Pt(1)
    x2 = 0.4 + split + 0.45
    text(s, x2, 1.25, W - x2 - 0.3, 0.5, head, size=txt_size + 2, bold=True, color=NAVY)
    bullets(s, x2, 1.85, W - x2 - 0.3, 5, items, size=txt_size - (2 if pics else 0), gap=6)
    if pics:
        cw = (W - x2 - 0.3) / len(pics)
        for i, (f, cap) in enumerate(pics):
            picture_fit(s, os.path.join(A, f), x2 + i * cw, 3.95, cw - 0.1, 2.6)
            text(s, x2 + i * cw, 6.55, cw - 0.1, 0.3, cap, size=11, color=GRAY, italic=True, align=PP_ALIGN.CENTER)
    if src:
        source(s, src)
    return s


def bullet_slide(title, items, size=22, src=None, pic=None, picw=4.6):
    s = frame(title)
    if pic:
        bullets(s, 0.6, 1.4, W - picw - 1.4, 5.3, items, size=size)
        picture_fit(s, os.path.join(A, pic), W - picw - 0.5, 1.3, picw, 5.2)
    else:
        bullets(s, 0.7, 1.4, W - 1.4, 5.3, items, size=size)
    if src:
        source(s, src)
    return s


def table_slide(title, rows, widths, size=16, src=None, y=1.4, rowh=0.5, note=None):
    s = frame(title)
    nr, nc = len(rows), len(rows[0])
    gt = s.shapes.add_table(nr, nc, Inches(0.5), Inches(y), Inches(sum(widths)), Inches(rowh * nr))
    t = gt.table
    for j, wd in enumerate(widths):
        t.columns[j].width = Inches(wd)
    for i, row in enumerate(rows):
        for j, val in enumerate(row):
            c = t.cell(i, j)
            c.text = ""
            p = c.text_frame.paragraphs[0]
            r = p.add_run(); r.text = val.replace('`', '')
            r.font.size = Pt(size); r.font.name = FONT
            c.fill.solid()
            if i == 0:
                c.fill.fore_color.rgb = NAVY; r.font.bold = True; r.font.color.rgb = WHITE
            else:
                c.fill.fore_color.rgb = PANEL if i % 2 else WHITE
                r.font.color.rgb = BLACK
                if j == 0:
                    r.font.bold = True; r.font.color.rgb = NAVY
            c.vertical_anchor = MSO_ANCHOR.MIDDLE
    if note:
        text(s, 0.5, y + rowh * nr + 0.2, W - 1.0, 0.9, note, size=17, color=BLACK)
    if src:
        source(s, src)
    return s


def section(big, small=None):
    s = prs.slides.add_slide(BLANK)
    page[0] += 1
    rect(s, 0, 0, W, H, WHITE)
    rect(s, 0, 0, 0.35, H, NAVY)
    rect(s, 0.35, 0, 0.12, H, GOLD)
    text(s, 1.0, 2.5, W - 2, 1.6, big, size=44, bold=True, color=NAVY,
         align=PP_ALIGN.CENTER, anchor=MSO_ANCHOR.MIDDLE)
    rect(s, W / 2 - 1.2, 4.25, 2.4, 0.07, GOLD)
    if small:
        text(s, 1.0, 4.5, W - 2, 1.0, small, size=22, color=GRAY, align=PP_ALIGN.CENTER)
    return s


# ---------------------------------------------------------------- 1. TIÊU ĐỀ
s = prs.slides.add_slide(BLANK)
rect(s, 0, 0, W, H, NAVY)
poly(s, [(455, 0), (693, 0), (693, 275)], WHITE)               # góc trắng phải-trên
poly(s, [(452, 0), (512, 0), (693, 198), (693, 262)], GOLD, line=WHITE, lw=2)
poly(s, [(0, 298), (0, 334), (56, 390), (96, 390)], GOLD, line=WHITE, lw=2)
s.shapes.add_picture(os.path.join(A, "logo_round.png"), Inches(W * 0.745), Inches(H * 0.14),
                     height=Inches(H * 0.27))
text(s, 0.75, 0.55, 8, 0.5, "KHOA ĐIỆN TỬ VIỄN THÔNG", size=20, color=WHITE)
text(s, 0.75, 1.55, 9.3, 0.6, "LẬP TRÌNH ĐA NỀN TẢNG", size=26, bold=True, color=GOLD)
text(s, 0.75, 2.35, 9.3, 1.5, "Chủ đề 5. Danh sách, lưới dữ liệu và cuộn", size=38, bold=True, color=WHITE)
text(s, 0.75, 3.95, 9.3, 0.5, "Flutter: ListView • GridView • Scroll • Lazy loading", size=20, color=GOLD)
text(s, 0.75, 5.0, 6.5, 1.5, "Sinh viên thực hiện:\nTrần Đăng Duy\nPhan Văn Trà", size=19, color=WHITE)
text(s, 7.4, 5.0, 5.4, 1.5, "Giảng viên hướng dẫn:\nNguyễn Duy Nhật Viễn", size=19, color=WHITE)

# ---------------------------------------------------------------- 2. NỘI DUNG
TAG[0] = ""
s = frame("Nội dung trình bày")
items = [
    ("**1. Cơ sở lý thuyết**", 0),
    ("ListView & ListView.builder  •  GridView & SliverGridDelegate", 1),
    ("ScrollController & lazy loading", 1),
    ("Cuộn lồng nhau, SingleChildScrollView, shrinkWrap", 1),
    ("Item kích thước khác nhau, trạng thái rỗng, RefreshIndicator", 1),
    ("**2. Thực hành – demo ứng dụng “Thư viện mini”**", 0),
    ("Chức năng ⇄ kiến thức & cấu trúc project", 1),
    ("Cuộn lồng nhau, lazy loading, tìm kiếm/rỗng, item co giãn", 1),
    ("GridView & trang chi tiết (SingleChildScrollView)", 1),
    ("**3. Kết luận & tài liệu tham khảo**", 0),
]
bullets(s, 0.9, 1.4, 11.5, 5.3, items, size=24, gap=10)

# ================================================================ PHẦN 1
T1 = "1 · CƠ SỞ LÝ THUYẾT"
TAG[0] = T1

code_slide("ListView & ListView.builder", """
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index]),
    );
  },
)
""", "Cuộn dọc / ngang, dựng lazy", [
    "**ListView(children)**: dựng toàn bộ con – chỉ dùng khi ít phần tử.",
    "**ListView.builder**: `itemBuilder` chỉ chạy cho item sắp hiện ra ⇒ hợp với danh sách dài.",
    "**.separated** thêm đường phân cách; `scrollDirection: Axis.horizontal` cho danh sách ngang.",
], split=5.9, pics=[("list_view.png", "ListView"), ("long-lists.png", "Long list (cookbook)")],
    src="docs.flutter.dev/cookbook/lists/long-lists · api.flutter.dev/flutter/widgets/ListView-class.html")

code_slide("GridView & SliverGridDelegate", """
GridView.builder(
  gridDelegate:
    SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.7,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
  itemCount: books.length,
  itemBuilder: (_, i) => BookCard(books[i]),
)
""", "Lưới 2 chiều, cũng lazy", [
    "**GridView.count / .extent / .builder**; `gridDelegate` quy định cách chia ô.",
    "**FixedCrossAxisCount**: cố định số cột. **MaxCrossAxisExtent**: ô rộng tối đa N px, số cột tự tính.",
    "**childAspectRatio** hoặc **mainAxisExtent** quyết định hình dạng ô ⇒ ô có kích thước cố định.",
], split=6.5, pics=[("gridview-count.png", "GridView.count"), ("gridview-extent.png", "GridView.extent")],
    src="api.flutter.dev/flutter/widgets/GridView-class.html · docs.flutter.dev/ui/layout (GridView)")

code_slide("ScrollController & lazy loading", """
_controller.addListener(() {
  final p = _controller.position;
  if (p.pixels >= p.maxScrollExtent - 200
      && !_isLoading && _hasMore) {
    _loadMore();
  }
});

// itemCount = 1 + books.length
//             + (_isLoading ? 1 : 0)
// item cuối: CircularProgressIndicator
""", "Cuộn gần cuối ⇒ tải thêm", [
    "**position.pixels** (vị trí hiện tại) so với **maxScrollExtent** (cuối danh sách).",
    "Cờ `_isLoading`, `_hasMore` chặn gọi trùng và dừng khi hết dữ liệu.",
    "Item cuối là vòng xoay tải; nhớ **dispose** ScrollController.",
], split=6.4, pics=[("mixed-list.png", "List cuộn (cookbook)")],
    src="api.flutter.dev/flutter/widgets/ScrollController-class.html · Viblo: “Lazy load trong Flutter” (viblo.asia/p/lazy-load-trong-flutter-3Q75wE03ZWb)")

code_slide("Cuộn lồng nhau & SingleChildScrollView", """
SizedBox(
  height: 160,        // bắt buộc cố định
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: featured.length,
    itemBuilder: (_, i) =>
        BookCard(book: featured[i]),
  ),
)
""", "Chọn đúng widget cuộn", [
    "**Cuộn lồng nhau**: ListView ngang là item 0 của ListView dọc; cần **chiều cao cố định**.",
    "Tránh `shrinkWrap: true` với dữ liệu dài: dựng hết item, mất lazy.",
    "**SingleChildScrollView**: nội dung ít, cố định (form, chi tiết); dựng cả con cùng lúc ⇒ **không** dùng cho danh sách dài.",
    "Gộp nhiều khối cuộn: **CustomScrollView + Sliver**.",
], split=6.4, pics=[("floating-app-bar.png", "CustomScrollView + SliverAppBar")],
    src="docs.flutter.dev/ui/layout/scrolling/slivers · Medium: “Common mistakes with ListViews in Flutter” (medium.com/@pomis172)")

code_slide("Item khác kích thước, trạng thái rỗng, làm mới", """
Text(description,
  maxLines: expanded ? null : 2,
  overflow: TextOverflow.ellipsis);

if (shown.isEmpty) {
  return const EmptyView(
    message: 'Không tìm thấy sách');
}

RefreshIndicator(
  onRefresh: _reload,
  child: ListView.builder(...),
)
""", "3 tình huống thường gặp", [
    "**Kích thước khác nhau**: không đặt `itemExtent`, ListView tự đo; mở rộng/thu gọn bằng `setState`.",
    "**Rỗng**: kiểm tra `isEmpty` ⇒ EmptyView (icon + thông báo).",
    "**Kéo để làm mới**: `RefreshIndicator`, `onRefresh` trả về Future.",
], split=6.1, pics=[("refresh.png", "RefreshIndicator")],
    src="api.flutter.dev/flutter/material/RefreshIndicator-class.html · docs.flutter.dev/cookbook/lists/long-lists")

# ================================================================ PHẦN 2
T2 = "2 · THỰC HÀNH – DEMO SẢN PHẨM"
TAG[0] = T2

s = table_slide("App “Thư viện mini”: chức năng ⇄ kiến thức", [
    ["Chức năng trong app", "Kiến thức minh họa"],
    ["2 tab: Danh sách / Lưới", "BottomNavigationBar, IndexedStack"],
    ["Danh sách sách + tải thêm khi cuộn", "ListView.builder, ScrollController"],
    ["“Sách nổi bật” cuộn ngang trong danh sách dọc", "Cuộn lồng nhau"],
    ["Mô tả dài/ngắn, “Xem thêm / Thu gọn”", "Phần tử kích thước khác nhau"],
    ["Tìm kiếm; không kết quả → EmptyView; kéo để làm mới", "Trạng thái rỗng, RefreshIndicator"],
    ["Lưới sách tự chia cột", "GridView.builder"],
    ["Trang chi tiết sách", "SingleChildScrollView"],
], [6.2, 6.3], size=17, rowh=0.55, y=1.3,
    note="Dữ liệu: assets/data/books_200.csv (200 cuốn) đọc bằng BookRepository (rootBundle + gói csv, cache Future). Không dùng DB/API, chỉ dùng setState.",
    src="lib/ : main, models/book, data/book_repository, screens/{home, book_list, book_grid, book_detail}, widgets/{book_tile, book_card, book_cover, empty_view}")

code_slide("Demo 1 – ListView.builder + cuộn lồng nhau", """
ListView.builder(
  controller: _controller,
  itemCount: prefixCount + visible + 1,
  itemBuilder: (context, index) {
    if (showFeatured && index == 0) {
      return _FeaturedSection(...);  // ngang
    }
    final i = index - prefixCount;
    if (i < visible) {
      return BookTile(book: results[i]);
    }
    return _isLoadingMore             // cuối
        ? const CircularProgressIndicator()
        : const Text('Đã hiển thị hết');
  },
)
// _FeaturedSection: SizedBox(height: 220)
//   └ ListView.builder(Axis.horizontal)
""", "Một ListView, 3 loại item", [
    "**itemCount = đầu + visible + 1**: dải nổi bật, sách đã hiển thị, ô cuối.",
    "Dải nổi bật là **ListView ngang** trong `SizedBox(height: 220)` ⇒ cuộn lồng nhau, vẫn lazy.",
    "Ô cuối: vòng xoay khi đang tải hoặc “Đã hiển thị hết”.",
], split=6.9, src="lib/screens/book_list_screen.dart")

code_slide("Demo 2 – Lazy loading bằng ScrollController", """
void _onScroll() {
  final p = _controller.position;
  if (p.pixels >= p.maxScrollExtent - 200) {
    _loadMore();
  }
}

Future<void> _loadMore() async {
  if (_isLoadingMore ||
      _visibleCount >= _results.length) return;
  setState(() => _isLoadingMore = true);
  await Future.delayed(
      const Duration(milliseconds: 350));
  if (!mounted) return;
  setState(() {
    _visibleCount = min(
        _visibleCount + _pageSize, _results.length);
    _isLoadingMore = false;
  });
}
""", "Mỗi lần tải thêm 20 sách", [
    "Còn **200 px** là hết ⇒ `_loadMore()`.",
    "Cờ `_isLoadingMore` và `_visibleCount >= length` chặn gọi trùng / dừng khi hết dữ liệu.",
    "`Future.delayed` giả lập thời gian tải trang; sau `await` kiểm tra `mounted`.",
    "(Code rút gọn; bản đầy đủ có `_generation` chống kết quả cũ.)",
], split=6.8, src="lib/screens/book_list_screen.dart")

code_slide("Demo 3 – Item co giãn, tìm kiếm & trạng thái rỗng", """
// BookTile: chiều cao item thay đổi
Text(book.description,
  maxLines: _expanded ? null : 2,
  overflow: _expanded
      ? TextOverflow.visible
      : TextOverflow.ellipsis);
TextButton(
  onPressed: () =>
      setState(() => _expanded = !_expanded),
  child: Text(_expanded ? 'Thu gọn' : 'Xem thêm'));

// Tìm kiếm → rỗng
if (results.isEmpty) {
  return _statusList(
    message: 'Không tìm thấy sách',
    action: 'Xóa tìm kiếm',
    onPressed: _clearQuery);
}
""", "Ba ý chính", [
    "Mô tả dài/ngắn ⇒ **chiều cao item khác nhau**; mặc định 2 dòng, “Xem thêm” mở hết.",
    "`searchBooks` lọc theo tên/tác giả; đổi từ khoá ⇒ về 20 phần tử đầu, `jumpTo(0)`.",
    "Không có kết quả ⇒ **EmptyView** + nút “Xóa tìm kiếm”.",
], split=6.5, src="lib/widgets/book_tile.dart · lib/screens/book_list_screen.dart · lib/data/book_repository.dart")

code_slide("Demo 4 – GridView.builder tự chia cột", """
LayoutBuilder(
  builder: (context, constraints) {
    final w = constraints.maxWidth;
    final columns =
        w < 350 ? 1 : max(2, ((w + 8) / 190).floor());
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: 250,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) =>
          BookCard(book: books[index]),
    );
  },
)
""", "Lưới thích ứng bề rộng", [
    "`LayoutBuilder` đọc bề rộng ⇒ tính **số cột** (< 350 px: 1 cột, còn lại ~190 px/cột).",
    "`mainAxisExtent: 250` cố định chiều cao ô ⇒ lưới đều.",
    "Dữ liệu nạp bằng **FutureBuilder** (tải / lỗi / rỗng / có dữ liệu).",
], split=6.8, src="lib/screens/book_grid_screen.dart")

code_slide("Demo 5 – Trang chi tiết: SingleChildScrollView", """
Scaffold(
  appBar: AppBar(title: Text(book.title)),
  body: SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 720),
        child: Column(children: [
          SizedBox(width: 180, height: 250,
              child: BookCover(book: book)),
          Text(book.title, ...),
          Text('Tác giả: ${book.authorNames}'),
          Text(book.description, ...), // dài
        ]),
      ),
    ),
  ),
)
""", "Một khối nội dung, độ dài thay đổi", [
    "Ảnh + vài dòng thông tin + mô tả dài ⇒ `SingleChildScrollView` + `Column`.",
    "Màn hình nhỏ/mô tả dài vẫn cuộn, không bị **overflow**.",
    "Hợp lý vì nội dung ít, cố định; không dùng cho danh sách dài.",
], split=6.6, src="lib/screens/book_detail_screen.dart")

# ================================================================ KẾT LUẬN
TAG[0] = "3 · KẾT LUẬN & TÀI LIỆU THAM KHẢO"
s = frame("Kết luận & tài liệu tham khảo")
bullets(s, 0.6, 1.3, 6.2, 5.5, [
    "**builder** (ListView/GridView) dựng lazy ⇒ xử lý tốt dữ liệu lớn.",
    "**ScrollController** phát hiện cuối danh sách để tải thêm.",
    "**SingleChildScrollView** cho nội dung ngắn; **shrinkWrap** làm mất lazy.",
    "App minh họa đủ: cuộn lồng nhau, item co giãn, rỗng, làm mới, lưới, chi tiết.",
], size=19, gap=10)
bullets(s, 7.0, 1.3, 6.0, 5.5, [
    "docs.flutter.dev/cookbook/lists (long-lists, grid-lists, horizontal-list)",
    "docs.flutter.dev/ui/layout/scrolling/slivers",
    "api.flutter.dev: ListView, GridView, SingleChildScrollView, ScrollController, RefreshIndicator",
    "Viblo: Lazy load trong Flutter (viblo.asia/p/lazy-load-trong-flutter-3Q75wE03ZWb)",
    "Viblo: Load more và pull to refresh với GridView (viblo.asia/p/jvEla3vdKkw)",
    "Medium: Flutter: Lazy Loading on Scroll Made Simple (@archelangelo)",
    "Medium: Common mistakes with ListViews in Flutter (@pomis172)",
    "Ảnh: flutter.github.io/assets-for-api-docs · docs.flutter.dev/assets/images",
], size=14, gap=5)

# ---------------------------------------------------------------- Cảm ơn
s = prs.slides.add_slide(BLANK)
page[0] += 1
rect(s, 0, 0, W, H, NAVY)
poly(s, [(455, 0), (693, 0), (693, 275)], WHITE)
poly(s, [(452, 0), (512, 0), (693, 198), (693, 262)], GOLD, line=WHITE, lw=2)
poly(s, [(0, 298), (0, 334), (56, 390), (96, 390)], GOLD, line=WHITE, lw=2)
s.shapes.add_picture(os.path.join(A, "logo_round.png"), Inches(W * 0.745), Inches(H * 0.14),
                     height=Inches(H * 0.27))
text(s, 0.75, 2.4, 9, 1.0, "CẢM ƠN THẦY VÀ CÁC BẠN", size=40, bold=True, color=GOLD)
text(s, 0.75, 3.5, 9, 0.8, "Xin mời đặt câu hỏi – Q&A", size=26, color=WHITE)
text(s, 0.75, 5.6, 9, 0.8, "Trần Đăng Duy • Phan Văn Trà", size=18, color=WHITE)

out = os.path.join(HERE, "slide_chu_de_5.pptx")
prs.save(out)
print("saved", out, "slides:", len(prs.slides))
