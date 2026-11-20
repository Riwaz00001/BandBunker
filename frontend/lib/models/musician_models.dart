class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String role;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };
}

class RegisterResponse {
  final String email;
  final String role;

  const RegisterResponse({
    required this.email,
    required this.role,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}

class LoginRequest {
  final String email;
  final String password;
  const LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
