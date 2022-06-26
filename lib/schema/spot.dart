class Spot {
  Spot({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.describe,
    required this.lat,
    required this.lon,
    required this.pictureUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.createdUserId,
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      title: json['title'].toString(),
      describe: json['describe'].toString(),
      // ignore: avoid_dynamic_calls
      lat: double.parse(json['location']['coordinates'][0].toString()),
      // ignore: avoid_dynamic_calls
      lon: double.parse(json['location']['coordinates'][1].toString()),
      pictureUrl: json['picture_url']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      createdUserId: json['uid'].toString(),
    );
  }
  final int id;
  final int categoryId;
  final String? title;
  final String? describe;
  final double lat;
  final double lon;
  final String? pictureUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdUserId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'category_id': categoryId,
      'title': title,
      'describe': describe,
      'lat': lat,
      'lon': lon,
      'picture_url': pictureUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_user_id': createdUserId,
    };
  }
}
