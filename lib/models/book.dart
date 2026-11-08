class Book {
  const Book({
    required this.isbn13,
    required this.isbn10,
    required this.title,
    required this.subtitle,
    required this.authors,
    required this.categories,
    required this.thumbnail,
    required this.description,
    required this.publishedYear,
    required this.averageRating,
    required this.numPages,
    required this.ratingsCount,
  });

  final String isbn13;
  final String isbn10;
  final String title;
  final String? subtitle;
  final List<String> authors;
  final String? categories;
  final String? thumbnail;
  final String description;
  final int? publishedYear;
  final double? averageRating;
  final int? numPages;
  final int? ratingsCount;

  String get authorNames => authors.join(', ');

  /// Chỉ đổi scheme cho URL bìa Google Books; không sửa nội dung CSV.
  String? get coverUrl {
    final String? value = thumbnail;
    if (value == null) return null;
    final Uri? uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAuthority) return null;
    if (uri.scheme == 'https') return value;
    if (uri.scheme == 'http' &&
        (uri.host == 'books.google.com' ||
            uri.host.endsWith('.books.google.com'))) {
      return uri.replace(scheme: 'https').toString();
    }
    return uri.scheme == 'http' ? value : null;
  }

  factory Book.fromCsvRecord(Map<String, String> record) {
    String value(String name) => record[name] ?? '';
    String? optional(String name) {
      final String text = value(name).trim();
      return text.isEmpty ? null : text;
    }

    return Book(
      isbn13: value('isbn13').trim(),
      isbn10: value('isbn10').trim(),
      title: value('title'),
      subtitle: optional('subtitle'),
      authors: value('authors')
          .split(';')
          .map((String author) => author.trim())
          .where((String author) => author.isNotEmpty)
          .toList(growable: false),
      categories: optional('categories'),
      thumbnail: optional('thumbnail'),
      description: value('description'),
      publishedYear: int.tryParse(value('published_year').trim()),
      averageRating: double.tryParse(value('average_rating').trim()),
      numPages: int.tryParse(value('num_pages').trim()),
      ratingsCount: int.tryParse(value('ratings_count').trim()),
    );
  }
}
