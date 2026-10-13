
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'queue_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => QueueProvider(),
      child: const WaitingRoomApp(),
    ),
  );
}

class WaitingRoomApp extends StatelessWidget {
  const WaitingRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WaitingRoomScreen(),
    );
  }
}

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final TextEditingController _controller = TextEditingController();

  void _addClient() {
    final name = _controller.text.trim();

    if (name.isNotEmpty) {
      context.read<QueueProvider>().addClient(name);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QueueProvider>();
    final clients = provider.clients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Waiting Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Client Name',
                    ),
                    onSubmitted: (_) => _addClient(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addClient,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Clients in Queue: ${clients.length}'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('nextClientButton'),
                onPressed: clients.isEmpty
                    ? null
                    : () {
                        context.read<QueueProvider>().nextClient();
                      },
                icon: const Icon(Icons.skip_next),
                label: const Text('Next Client'),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: clients.isEmpty
                  ? const Center(
                      child: Text('No clients in queue'),
                    )
                  : ListView.builder(
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        final clientName = clients[index];

                        return Card(
                          child: ListTile(
                            title: Text(clientName),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                context
                                    .read<QueueProvider>()
                                    .removeClient(clientName);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
