import 'job_offer.dart';

class Explanation {
  final List<String> pointsForts;
  final String       avisExpert;

  Explanation({
    required this.pointsForts,
    required this.avisExpert,
  });

  factory Explanation.fromJson(Map<String, dynamic> json) {
    return Explanation(
      pointsForts: List<String>.from(json['points_forts'] ?? []),
      avisExpert:  json['avis_expert'] ?? '',
    );
  }
}

class JobMatch {
  final String      id;
  final String      userId;
  final String      jobId;
  final int         score;
  final Explanation explanation;
  final JobOffer    jobOffer;

  JobMatch({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.score,
    required this.explanation,
    required this.jobOffer,
  });

  factory JobMatch.fromJson(Map<String, dynamic> json) {
    return JobMatch(
      id:          json['id'],
      userId:      json['user_id'],
      jobId:       json['job_id'],
      score:       json['score']       ?? 0,
      explanation: Explanation.fromJson(json['explanation']),
      jobOffer:    JobOffer.fromJson(json['job_offer']),
    );
  }
}