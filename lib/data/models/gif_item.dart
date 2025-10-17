class GifItem {
  final String url;
  final String title;

  GifItem({required this.url, required this.title});

  factory GifItem.fromJson(Map<String, dynamic> json) {
    final images = json['images'] ?? {};
    final downsized = images['downsized_medium'] ?? {};
    final original = images['original'] ?? {};
    final url = downsized['url'] ?? original['url'] ?? '';
    final title = json['title'] ?? 'Random GIF';
    return GifItem(url: url, title: title);
  }
}
