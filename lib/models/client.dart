class Client {
  final String id;
  final String name;
  final DateTime createdAt;
  final double? lat;
  final double? lng;

  const Client({
    required this.id,
    required this.name,
    required this.createdAt,
    this.lat,
    this.lng,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'].toString(),
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
    );
  }
}