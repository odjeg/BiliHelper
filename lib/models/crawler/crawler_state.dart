class CrawlerState {
  String url;
  String errorText;
  CrawlerState({this.url = '', this.errorText = ''});
  CrawlerState copyWith({String? url, String? errorText}) {
    return CrawlerState(
      url: url ?? this.url,
      errorText: errorText ?? this.errorText,
    );
  }
}
