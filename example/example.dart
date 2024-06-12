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
    queue.pull(duration: Duration(milliseconds: 200)).listen((event) {
      print(event.visibleAt);
      print(event.payload);
    });

    for (var i = 1; i <= 200; i++) {
      final payload = {'id': i, 'message': 'message $i'};
      await queue.send(payload);
    }

    // for (var i = 1; i <= 5; i++) {
    //   print((await queue.read(messageID: i))?.payload);
    // }
  } catch (e, stackTrace) {
    print(stackTrace);
    print(e.toString());
  }
}
