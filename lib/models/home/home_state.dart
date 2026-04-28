class HomeState {
  final String? mid;
  final String? uname;
  final String? imageUrl;

  HomeState({this.mid, this.uname, this.imageUrl});

  HomeState copyWith({String? mid, String? uname, String? imageUrl}) {
    return HomeState(
      mid: mid ?? this.mid,
      uname: uname ?? this.uname,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
