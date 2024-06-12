import 'package:dart_pgmq/src/message/message.dart';
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

    final (pausableTimer1, stream1) =
        queue.pausablePull(duration: Duration(milliseconds: 100));
    pausableTimer1.start();

    final (pausableTimer2, stream2) =
        queue.pausablePull(duration: Duration(milliseconds: 100));
    pausableTimer2.start();

    stream1.listen((event) async {
      print("Subscription 1: ${event.messageID}");
      print("Suscription 1 Deleted : ${await queue.delete(event.messageID)}");
    });

    stream2.listen((event) async {
      print("Subscription 2: ${event.messageID}");
      print("Suscription 2 Deleted : ${await queue.delete(event.messageID)}");
    });

    Future.delayed(Duration(seconds: 1), pausableTimer1.pause);

    Future.delayed(Duration(seconds: 10), pausableTimer1.start);

    for (var i = 1; i <= 20; i++) {
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
