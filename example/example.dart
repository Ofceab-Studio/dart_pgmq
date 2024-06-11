import 'package:dart_pgmq/src/pgmq/database_connection.dart';
import 'package:dart_pgmq/src/pgmq/pgmq.dart';

void main() async {
  final databaseParam = DatabaseConnectionParam(
      host: 'localhost',
      database: 'postgres',
      password: 'password',
      username: 'postgres',
      ssl: false,
      port: 5433);

  try {
    final pgmq = await Pgmq.createConnection(param: databaseParam);

    final queue = await pgmq.createQueue(queueName: 'yaya');
    final data = await queue.pop();
    print(data);
  } catch (e, stackTrace) {
    print(stackTrace);
    print(e.toString());
  }
}
