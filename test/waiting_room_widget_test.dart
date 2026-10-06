// test/waiting_room_manager_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:waiting_room_app_tp2/waiting_room_manager.dart';

void main() {
  test('doit ajouter un client à la liste d\'attente', () {
    // ARRANGE
    final manager = WaitingRoomManager();

    // ACT
    manager.addClient('John Doe');

    // ASSERT
    expect(manager.clients.length, 1);
    expect(manager.clients.first, 'John Doe');
  });

  test('doit supprimer un client de la liste', () {
    // ARRANGE
    final manager = WaitingRoomManager();
    manager.addClient('John Doe');
    manager.addClient('Jane Doe');

    // ACT
    manager.removeClient('John Doe');

    // ASSERT
    expect(manager.clients.length, 1);
    expect(manager.clients.first, 'Jane Doe');
  });
}