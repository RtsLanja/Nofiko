class JobOffer {
  final String   id;
  final String   title;
  final String   company;
  final String   location;
  final int      minXp;
  final String   levelRequired;
  final List<String> skillsRequired;
  final String   description;
  final String   category;
  final String   rawUrl;
  final DateTime postedAt;

  JobOffer({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.minXp,
    required this.levelRequired,
    required this.skillsRequired,
    required this.description,
    required this.category,
    required this.rawUrl,
    required this.postedAt,
  });

  factory JobOffer.fromJson(Map<String, dynamic> json) {
    return JobOffer(
      id:             json['id'],
      title:          json['title']          ?? 'Sans titre',
      company:        json['company']        ?? 'Inconnu',
      location:       json['location']       ?? '',
      minXp:          json['min_xp']         ?? 0,
      levelRequired:  json['level_required'] ?? 'Inconnu',
      skillsRequired: List<String>.from(json['skills_required'] ?? []),
      description:    json['description']    ?? '',
      category:       json['category']       ?? '',
      rawUrl:         json['raw_url']        ?? '',
      postedAt:       DateTime.parse(json['posted_at']),
    );
  }
}