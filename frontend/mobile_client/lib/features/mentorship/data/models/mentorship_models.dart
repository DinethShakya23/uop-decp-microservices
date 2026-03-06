class MentorshipProfileModel {
  final int? userId;
  final String role; // MENTOR, MENTEE
  final String department;
  final int yearsOfExperience;
  final List<String> expertise;
  final List<String> interests;
  final String bio;
  final String availability; // AVAILABLE, UNAVAILABLE, BUSY
  final String timezone;
  final String? linkedInUrl;

  const MentorshipProfileModel({
    this.userId,
    required this.role,
    required this.department,
    required this.yearsOfExperience,
    required this.expertise,
    required this.interests,
    required this.bio,
    required this.availability,
    required this.timezone,
    this.linkedInUrl,
  });

  factory MentorshipProfileModel.fromJson(Map<String, dynamic> json) {
    return MentorshipProfileModel(
      userId: json['userId'] as int?,
      role: json['role'] as String,
      department: json['department'] as String,
      yearsOfExperience: (json['yearsOfExperience'] as num).toInt(),
      expertise: (json['expertise'] as List?)?.map((e) => e as String).toList() ?? [],
      interests: (json['interests'] as List?)?.map((e) => e as String).toList() ?? [],
      bio: json['bio'] as String,
      availability: json['availability'] as String,
      timezone: json['timezone'] as String,
      linkedInUrl: json['linkedInUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'department': department,
        'yearsOfExperience': yearsOfExperience,
        'expertise': expertise,
        'interests': interests,
        'bio': bio,
        'availability': availability,
        'timezone': timezone,
        'linkedInUrl': linkedInUrl,
      };
}

class MatchModel {
  final int userId;
  final String userName;
  final MentorshipProfileModel profile;
  final double compatibilityScore;
  final List<String> commonInterests;

  const MatchModel({
    required this.userId,
    required this.userName,
    required this.profile,
    required this.compatibilityScore,
    required this.commonInterests,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String,
      profile: MentorshipProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
      compatibilityScore: (json['compatibilityScore'] as num).toDouble(),
      commonInterests: (json['commonInterests'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class MentorshipRequestModel {
  final int id;
  final int menteeId;
  final String menteeName;
  final int mentorId;
  final String mentorName;
  final String message;
  final List<String> topics;
  final String proposedDuration;
  final String status;
  final String createdAt;

  const MentorshipRequestModel({
    required this.id,
    required this.menteeId,
    required this.menteeName,
    required this.mentorId,
    required this.mentorName,
    required this.message,
    required this.topics,
    required this.proposedDuration,
    required this.status,
    required this.createdAt,
  });

  factory MentorshipRequestModel.fromJson(Map<String, dynamic> json) {
    return MentorshipRequestModel(
      id: (json['id'] as num).toInt(),
      menteeId: (json['menteeId'] as num).toInt(),
      menteeName: json['menteeName'] as String? ?? 'Student',
      mentorId: (json['mentorId'] as num).toInt(),
      mentorName: json['mentorName'] as String? ?? 'Alum/Staff',
      message: json['message'] as String,
      topics: (json['topics'] as List?)?.map((e) => e as String).toList() ?? [],
      proposedDuration: json['proposedDuration'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}

class RelationshipModel {
  final int id;
  final int menteeId;
  final String menteeName;
  final int mentorId;
  final String mentorName;
  final String goals;
  final String frequency;
  final String preferredChannel;
  final String status;
  final String createdAt;

  const RelationshipModel({
    required this.id,
    required this.menteeId,
    required this.menteeName,
    required this.mentorId,
    required this.mentorName,
    required this.goals,
    required this.frequency,
    required this.preferredChannel,
    required this.status,
    required this.createdAt,
  });

  factory RelationshipModel.fromJson(Map<String, dynamic> json) {
    return RelationshipModel(
      id: (json['id'] as num).toInt(),
      menteeId: (json['menteeId'] as num).toInt(),
      menteeName: json['menteeName'] as String? ?? 'Mentee',
      mentorId: (json['mentorId'] as num).toInt(),
      mentorName: json['mentorName'] as String? ?? 'Mentor',
      goals: json['goals'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      preferredChannel: json['preferredChannel'] as String? ?? '',
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
