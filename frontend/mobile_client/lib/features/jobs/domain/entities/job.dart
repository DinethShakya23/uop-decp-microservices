class Job {
  final int? id;
  final String title;
  final String description;
  final String company;
  final String location;
  final String type;
  final int postedBy;
  final String posterName;
  final String? createdAt;
  final String? updatedAt;

  const Job({
    this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.type,
    required this.postedBy,
    required this.posterName,
    this.createdAt,
    this.updatedAt,
  });
}