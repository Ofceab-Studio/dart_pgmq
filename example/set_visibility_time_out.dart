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
    final pgmq = await Pgmq.createConnection(param: databaseParam);

    final queue = await pgmq.createQueue(queueName: 'yaya');
    // Purge queue
    await queue.purgeQueue();

    final (pausableTimer, stream) = queue.pausablePull(
        duration: Duration(milliseconds: 100),
        visibilityDuration: Duration(seconds: 30));
    pausableTimer.start();

    stream.listen((event) async {
      if (event.payload['id'] is int && (event.payload['id'] % 2) == 0) {
        await queue.setVisibilityTimout(
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

    // final data = (await queue.read(maxReadNumber: 5));

    // for (final msg in data ?? <Message>[]) {
    //   print(msg.payload);
    // }
  } catch (e, stackTrace) {
    print(stackTrace);
    print(e.toString());
  }
}
