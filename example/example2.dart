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

  //  Create a queue
  final queue = await pgmq.createQueue(queueName: 'test');

  // Purge queue
  await queue.purgeQueue();
  print('purged');
  await Future.delayed(Duration(milliseconds: 3000));

  // Send message
  final payload = {'id': 1, 'message': 'message 1'};
  await queue.send(payload);
  print('message sent');
  await Future.delayed(Duration(milliseconds: 3000));

  // Read message
  final data = (await queue.read());
  for (final msg in data ?? <Message>[]) {
    print(msg.payload);
    final duration = Stopwatch()..start();
    await queue.delete(msg.messageID);
    duration.stop();
    print(duration.elapsed.inMilliseconds);
  }
}
