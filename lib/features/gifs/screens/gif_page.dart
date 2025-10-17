import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/controllers/gifs_controller.dart';
import '../../../data/services/giphy_service.dart';
import '../widgets/gif_display.dart';

const _giphyApiKey = 'GngoTYL5hz0ulTkrzphwVZ47vX5ibwbP';

class GifPage extends StatefulWidget {
  const GifPage({super.key});

  @override
  State<GifPage> createState() => _GifPageState();
}

class _GifPageState extends State<GifPage> {
  late final GifsController _controller;
  final TextEditingController _tagController = TextEditingController();
  Timer? _debounce;
  String _rating = 'g';

  @override
  void initState() {
    super.initState();
    final service = GiphyService(apiKey: _giphyApiKey);
    _controller = GifsController(service);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tagController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.trim().isNotEmpty) {
        _controller.fetchGifs(query.trim(), rating: _rating);
      }
    });
  }

  void _onRatingChanged(String? value) {
    if (value == null) return;
    setState(() => _rating = value);
    if (_tagController.text.trim().isNotEmpty) {
      _controller.fetchGifs(_tagController.text.trim(), rating: _rating);
      _controller.restartAutoShuffle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de GIFs'),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return IconButton(
                tooltip: _controller.autoShuffle
                    ? 'Pausar auto-shuffle'
                    : 'Retomar auto-shuffle',
                icon: Icon(
                  _controller.autoShuffle ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: _controller.toggleAutoShuffle,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtros e busca
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Procurar por TAG',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _rating,
                    onChanged: _onRatingChanged,
                    items: const [
                      DropdownMenuItem(value: 'g', child: Text('G')),
                      DropdownMenuItem(value: 'pg', child: Text('PG')),
                      DropdownMenuItem(value: 'pg-13', child: Text('PG-13')),
                      DropdownMenuItem(value: 'r', child: Text('R')),
                    ],
                  ),
                ],
              ),
            ),

            // Grid de GIFs com estados
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  if (_controller.gridLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_controller.gridError != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _controller.gridError!,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _controller.retryLastGridFetch,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_controller.gifGrid.isEmpty) {
                    return const Center(child: Text('Nenhum GIF encontrado.'));
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = (constraints.maxWidth / 150)
                          .floor()
                          .clamp(2, 6);

                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _controller.gifGrid.length,
                        itemBuilder: (context, index) {
                          final gif = _controller.gifGrid[index];
                          return GestureDetector(
                            onTap: () => _controller.trackOnClick(gif),
                            child: GifDisplay(
                              gif: gif,
                              onFirstFrame: _controller.trackOnLoad,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
