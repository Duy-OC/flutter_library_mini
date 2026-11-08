import 'package:flutter/material.dart';

import '../models/book.dart';

class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.book, this.fit = BoxFit.contain});

  final Book book;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final Color background =
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final String? url = book.coverUrl;
    return ColoredBox(
      color: background,
      child: url == null
          ? const _CoverFallback()
          : Image.network(
              url,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return const _CoverFallback();
              },
            ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.menu_book,
          size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
