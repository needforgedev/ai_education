class Cohort {
  final String id;
  final String name;
  final int minGrade;
  final int maxGrade;
  final bool isActive;

  const Cohort({
    required this.id,
    required this.name,
    required this.minGrade,
    required this.maxGrade,
    required this.isActive,
  });

  factory Cohort.fromJson(Map<String, dynamic> json) => Cohort(
        id: json['id'] as String,
        name: json['name'] as String,
        minGrade: json['min_grade'] as int,
        maxGrade: json['max_grade'] as int,
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'min_grade': minGrade,
        'max_grade': maxGrade,
        'is_active': isActive,
      };
}
