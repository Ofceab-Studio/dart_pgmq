import 'package:dart_pgmq/src/pgmq/database_connection.dart';
import 'package:dart_pgmq/src/pgmq/pgmq.dart';

void main() async {
  final databaseParam = DatabaseConnection(
      host: 'localhost',
      database: 'postgres',
      password: 'postgres',
      username: 'postgres',
      ssl: false,
      port: 5460);
  print("Start ...");
  try {
    // Create a pgmq connexion
    final pgmq = await Pgmq.createConnection(param: databaseParam);

    // Create a queue
    final queue = await pgmq.createQueue(queueName: 'queueName');

    // Purge queue
    await queue.purgeQueue();

    // Play with pausablePull
    final (pausableTimer, stream) = await queue.pausablePull(
        duration: Duration(milliseconds: 100),
        visibilityDuration: Duration(seconds: 30));
    pausableTimer.start();

    // Listen to stream then set vt
    stream.listen((event) async {
      if (event.payload['id'] is int && (event.payload['id'] % 2) == 0) {
        await queue.setVisibilityTimeout(
            messageID: event.messageID, duration: Duration(seconds: 10));
      }
      final dt = DateTime.now();
      print(
          '${(event.payload['id'] % 2) == 0} : ${dt.hour}:${dt.minute}:${dt.second}');
      print("message ID is ${event.payload['id']}");
    });

    for (var i = 1; i <= 5; i++) {
      await Future.delayed(Duration(seconds: 3));
      final payload = {'id': i, 'message': 'message $i'};
      await queue.send(payload);
    }
  } catch (e, stackTrace) {
    print(stackTrace);
    print(e.toString());
  }
}
