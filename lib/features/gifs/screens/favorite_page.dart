import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/controllers/gifs_controller.dart';
import '../widgets/gif_display.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final GifsController _controller;
  bool _loading = true;
  List gifs = [];

  @override
  void initState() {
    super.initState();
    _controller = context.read<GifsController>();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await _controller.getFavorites();
    setState(() {
      gifs = favs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : gifs.isEmpty
          ? const Center(child: Text('Nenhum favorito ainda.'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: gifs.length,
              itemBuilder: (context, index) {
                final gif = gifs[index];
                return Stack(
                  children: [
                    GifDisplay(gif: gif),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _controller.toggleFavorite(gif);
                          _loadFavorites();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
