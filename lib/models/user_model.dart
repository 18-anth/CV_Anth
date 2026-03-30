/// 👤 UserModel - Modelo de datos del usuario
class UserModel {
  final String email;
  final String? displayName;
  final DateTime? createdAt;

  UserModel({
    required this.email,
    this.displayName,
    this.createdAt,
  });

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Crea un modelo desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      displayName: json['displayName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  /// Copia el modelo con cambios opcionales
  UserModel copyWith({
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return UserModel(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
