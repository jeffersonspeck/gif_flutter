import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

const String _baseUrl = 'https://api.giphy.com/v1';

class GiphyService {
  final String apiKey;
  String? _randomId;

  GiphyService({required this.apiKey});

  /// Inicializa o random_id (necessário para analytics)
  /// Busca do cache ou faz uma chamada à API
  Future<void> initRandomId() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('giphy_random_id');

    if (cached != null && cached.isNotEmpty) {
      _randomId = cached;
      return;
    }

    if (apiKey.isEmpty) return;

    final uri = Uri.parse('$_baseUrl/randomid?api_key=$apiKey');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final id = (json['data']?['random_id'] ?? '') as String;
        if (id.isNotEmpty) {
          _randomId = id;
          await prefs.setString('giphy_random_id', id);
        }
      }
    } catch (_) {
      // Segue sem random_id se falhar
    }
  }

  /// Busca um GIF aleatório
  Future<GiphyGif?> fetchRandomGif({String? tag, String rating = 'g'}) async {
    if (apiKey.isEmpty) {
      throw Exception('API key não definida');
    }

    final params = <String, String>{
      'api_key': apiKey,
      if (tag != null && tag.trim().isNotEmpty) 'tag': tag.trim(),
      if (rating.isNotEmpty) 'rating': rating,
      if (_randomId != null) 'random_id': _randomId!,
    };

    final uri = Uri.https('api.giphy.com', '/v1/gifs/random', params);

    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;

        if (data == null || data.isEmpty) return null;

        return GiphyGif.fromJson(data);
      } else {
        throw Exception('Erro ${res.statusCode} ao buscar GIF');
      }
    } catch (e) {
      throw Exception('Falha de rede: $e');
    }
  }

  /// Busca vários GIFs por termo de pesquisa (para o grid)
  Future<List<GiphyGif>> searchGifs(
    String query, {
    int limit = 25,
    int offset = 0,
    String rating = 'g',
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('API key não definida');
    }

    final params = <String, String>{
      'api_key': apiKey,
      'q': query,
      'limit': '$limit',
      'offset': '$offset',
      'rating': rating,
      'lang': 'en',
    };

    final uri = Uri.https('api.giphy.com', '/v1/gifs/search', params);

    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final data = json['data'] as List<dynamic>;

        return data.map((item) => GiphyGif.fromJson(item)).toList();
      } else {
        throw Exception('Erro ${res.statusCode} ao buscar GIFs');
      }
    } catch (e) {
      throw Exception('Falha de rede: $e');
    }
  }

  /// Envia ping de analytics (fire-and-forget)
  Future<void> pingAnalytics(String? url) async {
    if (url == null) return;

    try {
      final uri = Uri.parse(url).replace(
        queryParameters: {
          ...Uri.parse(url).queryParameters,
          if (_randomId != null) 'random_id': _randomId!,
          'ts': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      await http.get(uri).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Silencioso
    }
  }

  /// Retorna o random_id atual (útil para debug)
  String? get randomId => _randomId;
}

/// Modelo de dados para um GIF do Giphy
class GiphyGif {
  final String? id;
  final String? title;
  final String? gifUrl;
  final String? analyticsOnLoad;
  final String? analyticsOnClick;

  GiphyGif({
    this.id,
    this.title,
    this.gifUrl,
    this.analyticsOnLoad,
    this.analyticsOnClick,
  });

  factory GiphyGif.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] ?? {}) as Map<String, dynamic>;
    final downsized = images['downsized_medium'] as Map<String, dynamic>?;
    final original = images['original'] as Map<String, dynamic>?;
    final url = (downsized?['url'] ?? original?['url']) as String?;

    final analytics = (json['analytics'] ?? {}) as Map<String, dynamic>;
    final onload = (analytics['onload']?['url']) as String?;
    final onclick = (analytics['onclick']?['url']) as String?;

    return GiphyGif(
      id: json['id'] as String?,
      title: (json['title'] ?? 'Random GIF') as String?,
      gifUrl: url,
      analyticsOnLoad: onload,
      analyticsOnClick: onclick,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'gifUrl': gifUrl,
      'analyticsOnLoad': analyticsOnLoad,
      'analyticsOnClick': analyticsOnClick,
    };
  }
}
