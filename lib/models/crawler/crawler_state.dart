class CrawlerState {
  String? url;
  String? errorText;
  CrawlerState({this.url, this.errorText});
  CrawlerState copyWith({
    String? url,
    String? errorText,
    bool clearErrorText = false,
  }) {
    return CrawlerState(
      url: url ?? this.url,
      errorText: clearErrorText ? null : errorText ?? this.errorText,
    );
  }
}
