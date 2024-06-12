import 'package:dart_pgmq/src/pgmq/database_connection.dart';
import 'package:dart_pgmq/src/pgmq/pgmq.dart';

void main() async {
  final databaseParam = DatabaseConnectionParam(
      host: 'localhost',
      database: 'postgres',
      password: 'password',
      username: 'postgres',
      ssl: false,
      port: 5455);

  try {
    final pgmq = await Pgmq.createConnection(param: databaseParam);

    final queue = await pgmq.createQueue(queueName: 'yaya');
    print("Hello here");
    // queue.pull(duration: Duration(milliseconds: 200)).listen((event) {
    //   print(event);
    // });
    final _ = await queue.send({"id": 1});
    await queue.send({"id": 2});
    await queue.send({"id": 3});
    await queue.send({"id": 4});
    final a = await queue.pop();
    print(a);
    // final data = await queue.pop();
  } catch (e, stackTrace) {
    print(stackTrace);
    print(e.toString());
  }
}
