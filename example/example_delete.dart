import 'package:dart_pgmq/dart_pgmq.dart';

Future<void> main() async {
  // Create a DatabaseConnection
  final databaseParam = DatabaseConnection(
      host: 'fallaciously-sterling-slug.data-1.use1.tembo.io',
      database: 'postgres',
      password: 'SvPlgCGC2o57KGGK',
      username: 'postgres',
      ssl: true,
      port: 5432);

  final a = Stopwatch()..start();
  // Create a connexion
  final pgmq = await Pgmq.createConnection(
      param: databaseParam,
      options: PoolConnectionOptions(
          maxConnection: 5,
          minConnection: 5,
          limitTimeout: Duration(minutes: 30),
          idleTimeout: Duration(hours: 1)));

  print("Initialized in ${a.elapsed.inMilliseconds}");

  //  Create a queue
  final queue = await pgmq.createQueue(queueName: 'test');

  await queue.purgeQueue();

  List<int> _messageIDs = [];

  // Send message
  for (var i = 1; i <= 40; i++) {
    final payload = {
      'id': i,
      'message':
          'message $i message $i message $i message $i message $i message $i message $i'
    };
    _messageIDs.add(await queue.send(payload));
    // print("Done saving ...");
  }

  final (pause, stream) = await queue.pausablePull(
      duration: Duration(milliseconds: 300),
      visibilityDuration: Duration(seconds: 40));
  pause.start();

  await Future.delayed(Duration(minutes: 3));

  for (var id in _messageIDs) {
    final stopWatch = Stopwatch()..start();
    await queue.delete(id);
    print("Delete $id: ${stopWatch.elapsedMilliseconds}");
    stopWatch.stop();
  }
}
