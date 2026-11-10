import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:waiting_room_app_tp2/models/client.dart';
import 'package:waiting_room_app_tp2/local_queue_service.dart';
import 'package:waiting_room_app_tp2/geolocation_service.dart';

class QueueProvider extends ChangeNotifier {
  final List<Client> _clients = [];
  List<Client> get clients => List.unmodifiable(_clients);

  final SupabaseClient? _supabaseOverride;
  SupabaseClient get _supabase =>
      _supabaseOverride ?? Supabase.instance.client;

  final LocalQueueService _localDb;
  final GeolocationService _geoService;
  final bool _remoteEnabled;

  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  Timer? _retryTimer;
  bool _syncing = false;

  QueueProvider({
    GeolocationService? geoService,
    LocalQueueService? localDb,
    SupabaseClient? supabase,
    bool autoStart = true,
  })  : _geoService = geoService ?? GeolocationService(),
        _localDb = localDb ?? LocalQueueService(),
        _supabaseOverride = supabase,
        _remoteEnabled = autoStart {
    if (autoStart) unawaited(initialize());
  }

  Future<void> initialize() async {
    await _refreshFromLocal();
    await _syncLocalToRemote();
    _setupRealtimeSubscription();

    // Retente la synchro régulièrement (retour du réseau)
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => unawaited(_syncLocalToRemote()),
    );
  }

  Future<void> _refreshFromLocal() async {
    try {
      final rows = await _localDb.getClients();
      _clients
        ..clear()
        ..addAll(rows.map(Client.fromMap));
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur SQLite : $e');
    }
  }

  Future<void> _syncLocalToRemote() async {
    if (!_remoteEnabled || _syncing) return;
    _syncing = true;
    try {
      final unsynced = await _localDb.getUnsyncedClients();
      for (final client in unsynced) {
        try {
          final remote = Map<String, dynamic>.from(client)
            ..remove('is_synced');
          await _supabase.from('clients').upsert(remote);
          await _localDb.markClientAsSynced(client['id'].toString());
        } catch (e) {
          debugPrint('Sync échouée pour ${client['id']} : $e');
        }
      }
    } catch (e) {
      debugPrint('Erreur SQLite : $e');
    } finally {
      _syncing = false;
    }
  }

  Future<void> _mergeWithRemote(List<Map<String, dynamic>> remoteRows) async {
    final merged = <String, Client>{};
    for (final row in remoteRows) {
      final c = Client.fromMap(row);
      merged[c.id] = c;
    }
    try {
      final unsynced = await _localDb.getUnsyncedClients();
      for (final row in unsynced) {
        final c = Client.fromMap(row);
        merged.putIfAbsent(c.id, () => c);
      }
    } catch (e) {
      debugPrint('Erreur SQLite (lecture) : $e');
    }
    final list = merged.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _clients
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

  void _setupRealtimeSubscription() {
    _subscription?.cancel();
    _subscription = _supabase
        .from('clients')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen(
      (rows) => unawaited(_mergeWithRemote(rows)),
      onError: (Object e) => debugPrint('Erreur Realtime : $e'),
    );
  }

  Future<void> addClient(String name) async {
    if (name.trim().isEmpty) return;

    final position = await _geoService.getCurrentPosition();

    final localClient = {
      'id': const Uuid().v4(),
      'name': name.trim(),
      'lat': position?.latitude,
      'lng': position?.longitude,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'is_synced': 0,
    };

    try {
      await _localDb.insertClientLocally(localClient);
    } catch (e) {
      debugPrint('Erreur SQLite (insertion) : $e');
    }

    _clients.add(Client.fromMap(localClient));
    _clients.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();

    unawaited(_syncLocalToRemote());
  }

  Future<void> removeClient(String id) async {
    try {
      await _localDb.deleteClientLocally(id);
    } catch (e) {
      debugPrint('Erreur SQLite (suppression) : $e');
    }
    _clients.removeWhere((c) => c.id == id);
    notifyListeners();

    if (!_remoteEnabled) return;
    try {
      await _supabase.from('clients').delete().eq('id', id);
    } catch (e) {
      debugPrint('Suppression distante échouée : $e');
    }
  }

  Future<void> nextClient() async {
    if (_clients.isEmpty) return;
    await removeClient(_clients.first.id);
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _subscription?.cancel();
    _localDb.close();
    super.dispose();
  }
}