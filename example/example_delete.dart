import 'package:dart_pgmq/dart_pgmq.dart';

Future<void> main() async {
  // Create a DatabaseConnection
  final databaseParam = DatabaseConnection(
      host: 'localhost',
      database: 'postgres',
      password: 'password',
      username: 'postgres',
      ssl: false,
      port: 5432);

  final a = Stopwatch()..start();
  // Create a connexion
  final pgmq = await Pgmq.createConnection(
      param: databaseParam,
      options: PoolConnectionOptions(
        maxConnection: 5,
      ));

  print("Initialized in ${a.elapsed.inMilliseconds}");

  //  Create a queue
  final queue = await pgmq.createQueue(queueName: 'test');

  await queue.purgeQueue();

  List<int> messageIDs = [];

  // Send message
  for (var i = 1; i <= 40; i++) {
    final payload = {
      'id': i,
      'message':
          'message $i message $i message $i message $i message $i message $i message $i'
    };
    final index = await queue.send(payload);
    if (index != null) {
      messageIDs.add(index);
    }
    // print("Done saving ...");
  }

  final (pause, _) = queue.pausablePull(
      duration: Duration(milliseconds: 300),
      visibilityDuration: Duration(seconds: 40));
  pause.start();

  await Future.delayed(Duration(minutes: 3));

  for (var id in messageIDs) {
    final stopWatch = Stopwatch()..start();
    await queue.delete(id);
    print("Delete $id: ${stopWatch.elapsedMilliseconds}");
    stopWatch.stop();
  }
}
