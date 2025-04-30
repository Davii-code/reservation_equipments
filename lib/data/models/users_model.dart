  class UserModel {
    final int? id;  // O id é agora opcional.
    final String login;
    final String password;
    final String confirmPassword;
    final String name;
    final String email;
    final String registrationCode;
    final bool active;

    UserModel({
      this.id,  // Torna o id opcional no construtor.
      required this.login,
      required this.password,
      required this.confirmPassword,
      required this.name,
      required this.email,
      required this.registrationCode,
      required this.active,
    });

    factory UserModel.fromJson(Map<String, dynamic> json) {
      return UserModel(
        id: json['id'],
        login: json['login'] as String? ?? '',
        password: json['password'] as String? ?? '',
        confirmPassword: json['confirmPassword'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        registrationCode: json['registrationCode'] as String? ?? '',
        active: json['active'] as bool? ?? false,
      );
    }


    Map<String, dynamic> toJson() {
      return {
        'id': id,  // O id agora é enviado se estiver presente.
        'login': login,
        'password': password,
        'confirmPassword': confirmPassword,
        'name': name,
        'email': email,
        'registrationCode': registrationCode,
        'active': active,
      };
    }

    Map<String, dynamic> toJsonUpdate() {
      return {
        'login': login,
        'name': name,
        'email': email,
        'registrationCode': registrationCode,
        'active': active,
      };
    }


    // Método para copiar o modelo, mantendo o id existente
    UserModel copyWith({
      int? id,
      String? login,
      String? password,
      String? confirmPassword,
      String? name,
      String? email,
      String? registrationCode,
      bool? active,
    }) {
      return UserModel(
        id: id ?? this.id,
        login: login ?? this.login,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
        name: name ?? this.name,
        email: email ?? this.email,
        registrationCode: registrationCode ?? this.registrationCode,
        active: active ?? this.active,
      );
    }
  }
