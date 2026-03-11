import './user.dart';


class ProfileRead {
  final String        id;
  final String        userId;
  final String        name;
  final int           xp;
  final String        level;
  final List<String>  skills;
  final String        location;
  final String?       rawCvText;
  final String        cvPath;
  final UserRead?     user;

  ProfileRead({
    required this.id,
    required this.userId,
    required this.name,
    required this.xp,
    required this.level,
    required this.skills,
    required this.location,
    this.rawCvText,
    required this.cvPath,
    this.user,
  });

  factory ProfileRead.fromJson(Map<String, dynamic> json) {
    return ProfileRead(
      id:         json['id'],
      userId:     json['user_id'],
      name:       json['name'],
      xp:         json['xp']      ?? 0,
      level:      json['level']   ?? 'Junior',
      skills:     List<String>.from(json['skills'] ?? []),
      location:   json['location'] ?? '',
      rawCvText:  json['raw_cv_text'],
      cvPath:     json['cv_path']  ?? '',
      user: json['user'] != null
          ? UserRead.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name':         name,
    'xp':           xp,
    'level':        level,
    'skills':       skills,
    'location':     location,
    'raw_cv_text':  rawCvText,
    'cv_path':      cvPath,
  };
}