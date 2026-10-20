
class Client {
  final int id;
  final String name;
  final DateTime createdAt;

  const Client({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as int,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
