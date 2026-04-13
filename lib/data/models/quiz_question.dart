class QuizQuestion {
  final String id;
  final String moduleId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final int orderIndex;

  const QuizQuestion({
    required this.id,
    required this.moduleId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.orderIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        moduleId: json['module_id'] as String,
        question: json['question'] as String,
        options: (json['options'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        correctIndex: json['correct_index'] as int,
        orderIndex: json['order_index'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'module_id': moduleId,
        'question': question,
        'options': options,
        'correct_index': correctIndex,
        'order_index': orderIndex,
      };
}
