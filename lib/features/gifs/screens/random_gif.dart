import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/controllers/gifs_controller.dart';
import '../widgets/gif_display.dart';

class RandomGifPage extends StatefulWidget {
  const RandomGifPage({super.key});

  @override
  State<RandomGifPage> createState() => _RandomGifPageState();
}

class _RandomGifPageState extends State<RandomGifPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GifsController>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GifsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GIF Aleatório'),
        actions: [
          IconButton(
            tooltip: controller.autoShuffle
                ? 'Pausar auto-shuffle'
                : 'Retomar auto-shuffle',
            icon: Icon(controller.autoShuffle ? Icons.pause : Icons.play_arrow),
            onPressed: controller.toggleAutoShuffle,
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: Center(
        child: controller.loading
            ? const CircularProgressIndicator()
            : controller.currentGif == null
            ? const Text('Nenhum GIF encontrado.')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GifDisplay(
                      gif: controller.currentGif!,
                      onFirstFrame: controller.trackOnLoad,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.currentGif!.title ?? 'Sem título',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<bool>(
                    future: controller.isFavorite(
                      controller.currentGif!.id ?? '',
                    ),
                    builder: (context, snapshot) {
                      final isFav = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isFav
                              ? Icons.favorite
                              : Icons.favorite_border_outlined,
                          color: Colors.pinkAccent,
                          size: 36,
                        ),
                        onPressed: () =>
                            controller.toggleFavorite(controller.currentGif!),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchRandom(rating: 'g'),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Novo GIF'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
