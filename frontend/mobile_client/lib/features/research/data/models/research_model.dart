class ResearchModel {
  final int? id;
  final String title;
  final String researchAbstract;
  final List<String> authors;
  final List<String> tags;
  final String? documentUrl;
  final String? doi;
  final String category;
  final int? postedBy;
  final String? posterName;
  final int? downloads;
  final String? createdAt;

  const ResearchModel({
    this.id,
    required this.title,
    required this.researchAbstract,
    required this.authors,
    required this.tags,
    this.documentUrl,
    this.doi,
    required this.category,
    this.postedBy,
    this.posterName,
    this.downloads,
    this.createdAt,
  });

  factory ResearchModel.fromJson(Map<String, dynamic> json) {
    return ResearchModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      title: json['title'] as String,
      researchAbstract: (json['researchAbstract'] ?? json['abstract'] ?? '') as String,
      authors: (json['authors'] as List?)?.map((e) => e as String).toList() ?? [],
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
      documentUrl: json['documentUrl'] as String?,
      doi: json['doi'] as String?,
      category: json['category'] as String,
      postedBy: json['postedBy'] != null ? (json['postedBy'] as num).toInt() : null,
      posterName: json['posterName'] as String?,
      downloads: json['downloads'] != null ? (json['downloads'] as num).toInt() : 0,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'researchAbstract': researchAbstract,
        'authors': authors,
        'tags': tags,
        'documentUrl': documentUrl,
        'doi': doi,
        'category': category,
      };
}
