import 'package:dart_pgmq/dart_pgmq.dart';

Future<void> main() async {
  // Create a DatabaseConnection
  final databaseParam = DatabaseConnection(
      host: 'localhost',
      database: 'postgres',
      password: 'postgres',
      username: 'postgres',
      ssl: false,
      port: 5460);

  // Create a connexion
  final pgmq = await Pgmq.createConnection(param: databaseParam);

  //  Create a queue
  final queue = await pgmq.createQueue(queueName: 'queueName');

  // Send message
  for (var i = 1; i <= 20; i++) {
    await Future.delayed(Duration(seconds: 3));
    final payload = {
      'id': i,
      'message':
          'message $i message $i message $i message $i message $i message $i message $i'
    };
    await queue.send(payload);
  }

  // Read message
  final data = (await queue.read(maxReadNumber: 5));
  for (final msg in data ?? <Message>[]) {
    print(msg.payload);
  }

  // Purge queue
  await queue.purgeQueue();
}
