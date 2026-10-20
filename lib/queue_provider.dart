
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waiting_room_app_tp2/models/client.dart';

class QueueProvider extends ChangeNotifier {
  final List<Client> _clients = [];

  List<Client> get clients => List.unmodifiable(_clients);

  final SupabaseClient _supabase = Supabase.instance.client;

  late final StreamSubscription<List<Map<String, dynamic>>>
      _subscription;

  QueueProvider() {
    _fetchInitialClients();
    _setupRealtimeSubscription();
  }

  Future<void> _fetchInitialClients() async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .order('created_at');

      _clients
        ..clear()
        ..addAll(response.map((row) => Client.fromMap(row)));

      notifyListeners();

      debugPrint('Clients récupérés : ${_clients.length}');
    } catch (error) {
      debugPrint('Erreur lors du chargement des clients : $error');
    }
  }

  void _setupRealtimeSubscription() {
    _subscription = _supabase
        .from('clients')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen(
      (rows) {
        _clients
          ..clear()
          ..addAll(rows.map((row) => Client.fromMap(row)));

        notifyListeners();

        debugPrint('Clients reçus en temps réel : ${_clients.length}');
      },
      onError: (Object error) {
        debugPrint('Erreur Realtime : $error');
      },
    );
  }

  Future<void> addClient(String name) async {
    if (name.trim().isEmpty) {
      debugPrint('Cannot add empty client name');
      return;
    }

    try {
      await _supabase
          .from('clients')
          .insert({'name': name.trim()});

      debugPrint('Client added: ${name.trim()}');
    } catch (error) {
      debugPrint('Failed to add client: $error');
    }
  }

  Future<void> removeClient(int id) async {
    try {
      await _supabase
          .from('clients')
          .delete()
          .eq('id', id);

      debugPrint('Client removed: $id');
    } catch (error) {
      debugPrint('Failed to remove client: $error');
    }
  }

  Future<void> nextClient() async {
    if (_clients.isEmpty) {
      debugPrint('Queue is empty!');
      return;
    }

    final firstClient = _clients.first;

    await removeClient(firstClient.id);

    debugPrint('Next client: ${firstClient.name}');
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
