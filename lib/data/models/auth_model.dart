class AuthDTO {
  final String login;
  final String password;

  AuthDTO({
    required this.login,
    required this.password,
  });

  factory AuthDTO.fromJson(Map<String, dynamic> json) {
    final login = json['login']?.toString() ?? '';
    final password = json['password']?.toString() ?? '';

    return AuthDTO(
      login: login,
      password: password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'password': password,
    };
  }
}