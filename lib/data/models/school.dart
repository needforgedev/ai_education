class School {
  final String id;
  final String name;
  final String registrationCode;
  final bool isActive;
  final DateTime createdAt;

  const School({
    required this.id,
    required this.name,
    required this.registrationCode,
    required this.isActive,
    required this.createdAt,
  });

  factory School.fromJson(Map<String, dynamic> json) => School(
        id: json['id'] as String,
        name: json['name'] as String,
        registrationCode: json['registration_code'] as String,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'registration_code': registrationCode,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };
}
