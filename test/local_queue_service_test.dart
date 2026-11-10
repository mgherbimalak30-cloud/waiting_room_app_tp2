import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waiting_room_app_tp2/local_queue_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Map<String, dynamic> client(String id, String name) => {
        'id': id,
        'name': name,
        'lat': 40.71,
        'lng': -74.00,
        'created_at': '2024-01-01T00:00:00Z',
        'is_synced': 0,
      };

  test('insertClientLocally ajoute un client', () async {
    final service = LocalQueueService(inMemory: true);
    await service.insertClientLocally(client('1', 'Alice'));

    final clients = await service.getUnsyncedClients();
    expect(clients.length, 1);
    expect(clients[0]['name'], 'Alice');
    await service.close();
  });

  test('markClientAsSynced retire le client des non synchronisés', () async {
    final service = LocalQueueService(inMemory: true);
    await service.insertClientLocally(client('1', 'Alice'));
    await service.markClientAsSynced('1');

    expect(await service.getUnsyncedClients(), isEmpty);
    expect((await service.getClients()).length, 1);
    await service.close();
  });

  test('deleteClientLocally supprime le client', () async {
    final service = LocalQueueService(inMemory: true);
    await service.insertClientLocally(client('1', 'Alice'));
    await service.deleteClientLocally('1');

    expect(await service.getClients(), isEmpty);
    await service.close();
  });
}