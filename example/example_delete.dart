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
  final queue = await pgmq.createQueue(queueName: 'newA');

  // Send message
  for (var i = 1; i <= 20; i++) {
    final payload = {
      'id': i,
      'message':
          'message $i message $i message $i message $i message $i message $i message $i'
    };
    await queue.send(payload);
    print("Done saving ...");
  }

  final (pause, stream) =
      await queue.pausablePull(duration: Duration(seconds: 1));
  pause.start();

  stream.listen((event) async {
    final stopWatch = Stopwatch()..start();

    await queue.delete(event.messageID);
    print("Delete ${event.messageID}: ${stopWatch.elapsedMilliseconds}");
    stopWatch.stop();
  });
}
