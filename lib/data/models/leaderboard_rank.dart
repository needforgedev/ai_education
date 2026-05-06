/// A single ranked row returned by the `get_leaderboard` Supabase RPC.
class LeaderboardRank {
  final String studentId;
  final String studentName;
  final double score;
  final int rank;

  const LeaderboardRank({
    required this.studentId,
    required this.studentName,
    required this.score,
    required this.rank,
  });

  factory LeaderboardRank.fromJson(Map<String, dynamic> json) =>
      LeaderboardRank(
        studentId: json['student_id'] as String,
        studentName: json['student_name'] as String,
        score: (json['score'] as num).toDouble(),
        rank: json['rank'] as int,
      );
}
