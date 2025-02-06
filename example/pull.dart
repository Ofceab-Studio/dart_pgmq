import 'package:dart_pgmq/dart_pgmq.dart';

Future<void> main() async {
  // Create a DatabaseConnection
  final databaseParam = DatabaseConnection(
      host: 'localhost',
      database: 'postgres',
      password: 'postgres',
      username: 'postgres',
      ssl: false,
      port: 5432);

  // Create a connexion
  final pgmq = await Pgmq.createConnection(param: databaseParam);

  //  Create a queue
  final queue = await pgmq.createQueue(queueName: 'test');

  // Purge queue
  await queue.purgeQueue();
  print('purged');
  // await Future.delayed(Duration(seconds: 3));

  final puller = queue.pull(duration: Duration(seconds: 1));

  // Send message
  for (var i = 0; i < 10; i++) {
    final payload = {'id': i, 'message': 'message $i'};
    queue.send(payload);
    // print('message sent');
  }

  // await Future.delayed(Duration(minutes: 3));

  puller.listen((event) async {
    final msg = event;
    final start = DateTime.now();
    await queue.delete(msg.messageID);
    final end = DateTime.now();
    print('time taken : ${end.difference(start).inMilliseconds}s');
    // duration.stop();
  });
}
