import 'package:flutter/material.dart';

import '../../../data/services/giphy_service.dart';

/// Widget para exibir um GIF do Giphy com analytics tracking
class GifDisplay extends StatefulWidget {
  final GiphyGif gif;
  final VoidCallback? onFirstFrame;
  final VoidCallback? onTap;

  const GifDisplay({
    super.key,
    required this.gif,
    this.onFirstFrame,
    this.onTap,
  });

  @override
  State<GifDisplay> createState() => _GifDisplayState();
}

class _GifDisplayState extends State<GifDisplay> {
  bool _firedOnLoad = false;

  @override
  void didUpdateWidget(GifDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset quando o GIF muda
    if (oldWidget.gif.id != widget.gif.id) {
      _firedOnLoad = false;
    }
  }

  void _handleFirstFrame() {
    if (!_firedOnLoad && widget.onFirstFrame != null) {
      _firedOnLoad = true;
      // Executa após o frame atual para garantir que o widget está montado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onFirstFrame?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gifUrl = widget.gif.gifUrl;

    if (gifUrl == null || gifUrl.isEmpty) {
      return const Center(child: Text('URL do GIF não disponível'));
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Image.network(
        gifUrl,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        // Dispara o callback quando a primeira frame chegar
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame != null) {
            _handleFirstFrame();
          }
          return child;
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return const SizedBox(
            width: 64,
            height: 64,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  'Erro ao carregar GIF',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
