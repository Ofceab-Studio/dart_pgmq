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

  // Create a connexion
  final pgmq = await Pgmq.createConnection(param: databaseParam);
  // final pgmq1 = await Pgmq.createConnection(param: databaseParam);

  //  Create a queue
  final queue = await pgmq.createQueue(queueName: 'test');
  // final queue1 = await pgmq1.createQueue(queueName: 'test');

  // Purge queue
  await queue.purgeQueue();
  print('purged');
  // await Future.delayed(Duration(seconds: 3));

  final (pause, stream) = queue.pausablePull(
      duration: Duration(milliseconds: 300),
      visibilityDuration: Duration(seconds: 50));

  pause.start();

  // Send message
  for (var i = 0; i < 100; i++) {
    final payload = {'id': i, 'message': 'message $i'};
    queue.send(payload);
    // print('message sent');
  }

  await Future.delayed(Duration(minutes: 3));

  stream.listen((event) async {
    final msg = event;
    final start = DateTime.now();
    await queue.delete(msg.messageID);
    final end = DateTime.now();
    print('time taken : ${end.difference(start).inMilliseconds}');
  });

  // final data = (await queue.read());

  // Read message
  // for (final msg in data ?? <Message>[]) {
}
