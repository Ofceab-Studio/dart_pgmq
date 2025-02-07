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

  final (pause, stream) = queue.pausablePull(
      duration: Duration(seconds: 1), visibilityDuration: Duration(seconds: 0));

  pause.start();

  // Send message
  for (var i = 0; i < 1000; i++) {
    final payload = {'id': i, 'message': 'message $i'};
    await Future.delayed(Duration(seconds: 5));
    queue.send(payload);
    print('message $i sent');
  }

  // await Future.delayed(Duration(minutes: 3));

  stream.listen((event) async {
    final msg = event;
    final start = DateTime.now();
    await queue.delete(msg.messageID);
    final end = DateTime.now();
    print('time taken : ${end.difference(start).inMilliseconds}');
  });
}
