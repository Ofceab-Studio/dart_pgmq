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

    // queue.pull(duration: Duration(milliseconds: 200)).listen((event) async {
    //   print(event.visibleAt);
    //   print(event.messageID);
    //   print("Deleted : ${await queue.delete(event.messageID)}");
    // });

    for (var i = 1; i <= 5; i++) {
      final payload = {'id': i, 'message': 'message $i'};
      await queue.send(payload);
    }

    final data = (await queue.read(maxReadNumber: 5));

    for (final msg in data ?? <Message>[]) {
      print(msg.payload);
    }
  } catch (e, stackTrace) {
    print(stackTrace);
    print(e.toString());
  }
}
