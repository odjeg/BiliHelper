class LoginState {
  String? url;
  String? qrcodeKey;
  String? message;
  bool isRequesting;
  bool isLoginSuccess;

  LoginState({
    required this.url,
    required this.qrcodeKey,
    required this.message,
    required this.isRequesting,
    required this.isLoginSuccess,
  });

  LoginState copyWith({
    String? url,
    String? qrcodeKey,
    String? message,
    bool? isRequesting,
    bool? isLoginSuccess,
  }) => LoginState(
    url: url ?? this.url,
    qrcodeKey: qrcodeKey ?? this.qrcodeKey,
    message: message ?? this.message,
    isRequesting: isRequesting ?? this.isRequesting,
    isLoginSuccess: isLoginSuccess ?? this.isLoginSuccess,
  );
}
