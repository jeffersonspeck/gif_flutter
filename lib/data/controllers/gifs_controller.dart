import 'dart:async';
import 'package:flutter/material.dart';
import '../services/giphy_service.dart';
import '../services/local_storage.dart'; // <- Nosso DatabaseService

class GifsController extends ChangeNotifier {
  final GiphyService _service;
  final DatabaseService _db = DatabaseService();
  String? get lastQuery => _lastQuery;

  GifsController(this._service);

  // ---------------- Estado GIF aleatório ----------------
  GiphyGif? currentGif;
  bool loading = false;
  bool autoShuffle = true;
  bool _trackedOnLoad = false;

  // ---------------- Estado Grid ----------------
  List<GiphyGif> gifGrid = [];
  bool gridLoading = false;
  String? gridError;
  String? _lastQuery;
  String _lastRating = 'g';

  // ---------------- Timer auto-shuffle ----------------
  Timer? _timer;
  static const Duration _shuffleInterval = Duration(seconds: 7);

  /// Inicializa o controller: random_id + primeiro GIF
  Future<void> init() async {
    await _service.initRandomId();
    await fetchRandom();
    _startAutoShuffle();
  }

  /// Alterna modo auto-shuffle
  void toggleAutoShuffle() {
    autoShuffle = !autoShuffle;
    if (autoShuffle) {
      _startAutoShuffle();
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }

  /// Inicia o timer de auto-shuffle
  void _startAutoShuffle() {
    _timer?.cancel();
    if (!autoShuffle) return;

    _timer = Timer.periodic(_shuffleInterval, (_) {
      if (!loading) fetchRandom(tag: _lastQuery, rating: _lastRating);
    });
  }

  /// Busca GIF aleatório
  Future<void> fetchRandom({String? tag, String rating = 'g'}) async {
    loading = true;
    _trackedOnLoad = false;
    _lastQuery = tag;
    _lastRating = rating;
    notifyListeners();

    try {
      final gif = await _service.fetchRandomGif(tag: tag, rating: rating);
      currentGif = gif;
    } catch (e) {
      currentGif = null;
      debugPrint('Erro ao buscar GIF: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Busca GIFs para o Grid
  Future<void> fetchGifs(String query, {String rating = 'g'}) async {
    gridLoading = true;
    gridError = null;
    _lastQuery = query;
    _lastRating = rating;
    notifyListeners();

    try {
      final results = await _service.searchGifs(query, rating: rating);
      gifGrid = results;
    } catch (e) {
      gridError = e.toString();
      gifGrid = [];
    } finally {
      gridLoading = false;
      notifyListeners();
    }
  }

  /// Retry para grid
  void retryLastGridFetch() {
    if (_lastQuery != null) {
      fetchGifs(_lastQuery!, rating: _lastRating);
    }
  }

  // ---------------- Analytics ----------------
  void trackOnLoad() {
    if (_trackedOnLoad || currentGif == null) return;
    _trackedOnLoad = true;
    _service.pingAnalytics(currentGif!.analyticsOnLoad);
  }

  void trackOnClick([GiphyGif? gif]) {
    final targetGif = gif ?? currentGif;
    if (targetGif == null) return;
    _service.pingAnalytics(targetGif.analyticsOnClick);
  }

  // ---------------- Favoritos ----------------
  Future<void> toggleFavorite(GiphyGif gif) async {
    final isFav = await _db.isFavorite(gif.id!);
    if (isFav) {
      await _db.removeFavorite(gif.id!);
    } else {
      await _db.addFavorite(gif.id!, gif.title ?? '', gif.gifUrl ?? '');
    }
    notifyListeners();
  }

  Future<List<GiphyGif>> getFavorites() async {
    final favs = await _db.getFavorites();
    return favs
        .map((f) => GiphyGif(id: f['id'], title: f['title'], gifUrl: f['url']))
        .toList();
  }

  Future<bool> isFavorite(String id) async {
    return await _db.isFavorite(id);
  }

  // ---------------- Histórico ----------------
  Future<void> addHistory(String query) async {
    await _db.addHistory(query);
  }

  Future<List<String>> getHistory() async {
    final history = await _db.getHistory();
    return history.map((h) => h['query'] as String).toList();
  }

  // ---------------- Preferências ----------------
  Future<void> setPreference(String key, String value) async {
    await _db.setPreference(key, value);
  }

  Future<String?> getPreference(String key) async {
    return await _db.getPreference(key);
  }

  // ---------------- Reinicia auto-shuffle ----------------
  void restartAutoShuffle() {
    if (autoShuffle) _startAutoShuffle();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
