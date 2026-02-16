class Report {
  final int id;
  final String title;
  final String folio;
  final String description;
  final String imageUrl;
  final DateTime createdAt;
  final int status;

  Report({
    required this.id,
    required this.title,
    required this.folio,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    required this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'],
      folio: json['folio'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
    );
  }
}