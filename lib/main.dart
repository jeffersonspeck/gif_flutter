import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/controllers/gifs_controller.dart';
import 'data/services/giphy_service.dart';
import 'features/gifs/screens/gif_page.dart';
import 'features/gifs/screens/search_gif_page.dart';
import 'features/gifs/screens/favorite_page.dart';
import 'features/gifs/screens/history_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GifsController(
        GiphyService(apiKey: 'GngoTYL5hz0ulTkrzphwVZ47vX5ibwbP'),
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GIF Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => GifPage(), // Página inicial
        '/search': (_) => SearchGifPage(), // Página de busca
        '/favorites': (_) => FavoritesPage(), // Página de favoritos
        '/history': (_) => HistoryPage(), // Página de histórico
      },
    );
  }
}
