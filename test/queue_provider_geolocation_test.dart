import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waiting_room_app_tp2/geolocation_service.dart';
import 'package:waiting_room_app_tp2/local_queue_service.dart';
import 'package:waiting_room_app_tp2/queue_provider.dart';

class FakeGeolocationService extends GeolocationService {
  final Position? position;
  FakeGeolocationService(this.position);

  @override
  Future<Position?> getCurrentPosition() async => position;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  QueueProvider buildProvider(Position? position) {
    return QueueProvider(
      geoService: FakeGeolocationService(position),
      localDb: LocalQueueService(inMemory: true),
      autoStart: false, // pas de Supabase dans les tests
    );
  }

  test('addClient enregistre le client avec la géolocalisation', () async {
    final provider = buildProvider(
      Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ),
    );

    await provider.addClient('Test User');

    final client = provider.clients.last;
    expect(client.name, 'Test User');
    expect(client.lat, 37.7749);
    expect(client.lng, -122.4194);
    provider.dispose();
  });

  test('addClient stocke null si la position est indisponible', () async {
    final provider = buildProvider(null);

    await provider.addClient('Sans GPS');

    final client = provider.clients.last;
    expect(client.lat, isNull);
    expect(client.lng, isNull);
    provider.dispose();
  });

  test('addClient ignore un nom vide', () async {
    final provider = buildProvider(null);

    await provider.addClient('   ');

    expect(provider.clients, isEmpty);
    provider.dispose();
  });
}