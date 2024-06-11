import '../exception/pgmq_exception.dart';
import '../queue/queue.dart';
import 'database_connection.dart';
import 'package:postgres/postgres.dart';

part 'pgmq.part.dart';

abstract class Pgmq {
  /// Create queue
  /// [queueName] : name of the queue
  static Future<Pgmq> createConnection(
      {required DatabaseConnectionParam param}) async {
    try {
      final dbConnection = await Connection.open(
          Endpoint(
            host: param.host,
            database: param.database,
            username: param.username,
            password: param.password,
            port: param.port,
          ),
          settings: ConnectionSettings(
            sslMode: param.ssl ? SslMode.require : SslMode.disable,
          ));

      return _Pgmp(connection: dbConnection);
    } catch (e, stack) {
      print(stack);
      throw GenericPgmqException(
          message: 'Unable to connect to database\n${e.toString()}');
    }
  }

  Future<Queue> createQueue({required String queueName});
}
