import 'package:dart_pgmq/dart_pgmq.dart';

Future<void> main() async {
  // Create a DatabaseConnection

  final databaseParam = DatabaseConnection(
      host: 'vigorously-enchanting-mammoth.data-1.use1.tembo.io',
      database: 'postgres',
      password: '4ytDQIJHnXjrIeu7',
      username: 'postgres',
      ssl: true,
      port: 5432);

  // Create a connexion
  final pgmq =
      await Pgmq.createConnection(param: databaseParam, usePostgres: true);

  //  Create a queue
  final queue = await pgmq.createQueue(queueName: 'queueName');

  // Send message
  for (var i = 1; i <= 2; i++) {
    await Future.delayed(Duration(seconds: 3));
    final payload = {
      'id': i,
      'message':
          'message $i message $i message $i message $i message $i message $i message $i'
    };
    final stop = Stopwatch()..start();
    await queue.send(payload);
    print(stop.elapsedMilliseconds);
    stop.stop();
  }

  // Read message
  final data = (await queue.read(maxReadNumber: 5));
  for (final msg in data ?? <Message>[]) {
    print(msg.payload);
    final seMessage = await queue.setVisibilityTimeout(
        messageID: msg.messageID, duration: Duration(seconds: 10));
    print('From set ${seMessage?.messageID}\n${seMessage?.payload}');
  }

  for (var i = 0; i < 10; i++) {
    final a = await queue.pop();
    print(a);
  }

  // Purge queue
  await queue.purgeQueue();
}
