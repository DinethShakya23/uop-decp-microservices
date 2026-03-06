import 'package:decp_mobile_app/features/jobs/domain/entities/job.dart';

class JobModel extends Job {
  const JobModel({
    super.id,
    required super.title,
    required super.description,
    required super.company,
    required super.location,
    required super.type,
    required super.postedBy,
    required super.posterName,
    super.createdAt,
    super.updatedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      title: json['title'] as String,
      description: json['description'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      postedBy: (json['postedBy'] as num).toInt(),
      posterName: json['posterName'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'company': company,
        'location': location,
        'type': type,
        'postedBy': postedBy,
        'posterName': posterName,
      };
}

class JobApplicationModel {
  final int? id;
  final int jobId;
  final int userId;
  final String applicantName;
  final String? coverLetter;
  final String? resumeUrl;
  final String status;

  const JobApplicationModel({
    this.id,
    required this.jobId,
    required this.userId,
    required this.applicantName,
    this.coverLetter,
    this.resumeUrl,
    required this.status,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      jobId: (json['jobId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      applicantName: json['applicantName'] as String,
      coverLetter: json['coverLetter'] as String?,
      resumeUrl: json['resumeUrl'] as String?,
      status: json['status'] as String,
    );
  }
}
