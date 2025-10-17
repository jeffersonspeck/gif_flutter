import 'package:flutter/material.dart';
import '../../../data/models/gif_item.dart';

class GifTile extends StatelessWidget {
  final GifItem gif;

  const GifTile({super.key, required this.gif});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.network(
            gif.url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          gif.title,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
