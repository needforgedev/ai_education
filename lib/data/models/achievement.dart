/// A single achievement entry — pure data, no UI.
class Achievement {
  /// Stable id for analytics + de-duplication.
  final String id;
  final String emoji;
  final String title;

  /// Plain-language unlock criterion. Shown as the hint on locked tiles.
  final String description;

  /// True when the unlock predicate has been satisfied for the current student.
  final bool earned;

  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.earned,
  });
}
