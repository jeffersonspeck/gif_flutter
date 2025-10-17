import 'package:flutter/material.dart';
import 'package:aula04/data/models/gif_item.dart';
import 'package:aula04/features/gifs/widgets/gif_tile.dart';

class GifGrid extends StatelessWidget {
  final List<GifItem> gifs;

  const GifGrid({super.key, required this.gifs});

  @override
  Widget build(BuildContext context) {
    // Usa GridView para mostrar os GIFs
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: gifs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Ajusta automaticamente o número de colunas
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return GifTile(gif: gifs[index]);
      },
    );
  }
}
