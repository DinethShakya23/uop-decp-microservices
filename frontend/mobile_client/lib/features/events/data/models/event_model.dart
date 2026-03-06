class EventModel {
  final int? id;
  final String title;
  final String description;
  final String location;
  final String eventDate;
  final String startTime;
  final String endTime;
  final int? organizer;
  final String? organizerName;
  final String category;
  final int maxAttendees;
  final String? createdAt;
  final int? attendeeCount;

  const EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    this.organizer,
    this.organizerName,
    required this.category,
    required this.maxAttendees,
    this.createdAt,
    this.attendeeCount,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      eventDate: json['eventDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      organizer: json['organizer'] != null ? (json['organizer'] as num).toInt() : null,
      organizerName: json['organizerName'] as String?,
      category: json['category'] as String,
      maxAttendees: (json['maxAttendees'] as num).toInt(),
      createdAt: json['createdAt'] as String?,
      attendeeCount: json['attendeeCount'] != null ? (json['attendeeCount'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'location': location,
        'eventDate': eventDate,
        'startTime': startTime,
        'endTime': endTime,
        'category': category,
        'maxAttendees': maxAttendees,
      };
}

class RsvpModel {
  final int? id;
  final int eventId;
  final int userId;
  final String? userName;
  final String status;
  final String? respondedAt;

  const RsvpModel({
    this.id,
    required this.eventId,
    required this.userId,
    this.userName,
    required this.status,
    this.respondedAt,
  });

  factory RsvpModel.fromJson(Map<String, dynamic> json) {
    return RsvpModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      eventId: (json['eventId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String?,
      status: json['status'] as String,
      respondedAt: json['respondedAt'] as String?,
    );
  }
}
