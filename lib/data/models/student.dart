class Student {
  final String id;
  final String fullName;
  final String email;
  final int grade;
  final String schoolId;
  final String cohortId;
  final String? guardianContact;
  final DateTime joinedAt;

  const Student({
    required this.id,
    required this.fullName,
    required this.email,
    required this.grade,
    required this.schoolId,
    required this.cohortId,
    this.guardianContact,
    required this.joinedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        email: json['email'] as String,
        grade: json['grade'] as int,
        schoolId: json['school_id'] as String,
        cohortId: json['cohort_id'] as String,
        guardianContact: json['guardian_contact'] as String?,
        joinedAt: DateTime.parse(json['joined_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'grade': grade,
        'school_id': schoolId,
        'cohort_id': cohortId,
        'guardian_contact': guardianContact,
        'joined_at': joinedAt.toIso8601String(),
      };
}
