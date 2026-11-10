import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waiting_room_app_tp2/geolocation_service.dart';
import 'package:waiting_room_app_tp2/local_queue_service.dart';
import 'package:waiting_room_app_tp2/queue_provider.dart';

class FakeGeo extends GeolocationService {
  @override
  Future<Position?> getCurrentPosition() async => null;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('QueueProvider Tests', () {
    late QueueProvider provider;

    setUp(() {
      provider = QueueProvider(
        geoService: FakeGeo(),
        localDb: LocalQueueService(inMemory: true),
        autoStart: false, // pas de Supabase dans les tests
      );
    });

    tearDown(() => provider.dispose());

    test('nextClient removes the first client', () async {
      await provider.addClient('Client A');
      await provider.addClient('Client B');

      await provider.nextClient();

      expect(provider.clients.length, 1);
      expect(provider.clients.first.name, 'Client B');
    });

    test('nextClient does nothing when queue is empty', () async {
      await provider.nextClient();

      expect(provider.clients, isEmpty);
    });
  });
}