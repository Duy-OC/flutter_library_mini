import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.menu_book,
              size: 72, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
