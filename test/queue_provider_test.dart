
import 'package:flutter_test/flutter_test.dart';
import 'package:waiting_room_app_tp2/queue_provider.dart';

void main() {
  group('QueueProvider Tests', () {
    test('nextClient removes the first client', () {
      final provider = QueueProvider();

      provider.addClient('Client A');
      provider.addClient('Client B');

      provider.nextClient();

      expect(provider.clients.length, 1);
      expect(provider.clients.first, 'Client B');
    });

    test('nextClient does nothing when queue is empty', () {
      final provider = QueueProvider();

      provider.nextClient();

      expect(provider.clients, isEmpty);
    });
  });
}
