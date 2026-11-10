import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:waiting_room_app_tp2/main.dart';
import 'package:waiting_room_app_tp2/models/client.dart';
import 'package:waiting_room_app_tp2/queue_provider.dart';

class FakeQueueProvider extends QueueProvider {
  final List<Client> fakeClients;
  FakeQueueProvider(this.fakeClients) : super(autoStart: false);

  @override
  List<Client> get clients => fakeClients;
}

Future<void> pumpScreen(WidgetTester tester, List<Client> clients) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<QueueProvider>.value(
      value: FakeQueueProvider(clients),
      child: const MaterialApp(home: WaitingRoomScreen()),
    ),
  );
}

void main() {
  testWidgets('Affiche la localisation quand elle est disponible',
      (tester) async {
    await pumpScreen(tester, [
      Client(
        id: '1',
        name: 'Sam',
        createdAt: DateTime.now(),
        lat: 51.5074,
        lng: -0.1278,
      ),
    ]);

    expect(find.text('Sam'), findsOneWidget);
    expect(find.textContaining('51.5074'), findsOneWidget);
  });

  testWidgets('Affiche "Location not captured" sans position',
      (tester) async {
    await pumpScreen(tester, [
      Client(id: '2', name: 'Lea', createdAt: DateTime.now()),
    ]);

    expect(find.textContaining('Location not captured'), findsOneWidget);
  });
}