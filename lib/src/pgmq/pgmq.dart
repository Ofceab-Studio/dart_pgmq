import 'package:postgresql2/postgresql.dart' as postgresql2;

import '../exception/pgmq_exception.dart';
import '../queue/queue.dart';
import 'database_connection.dart';
import 'package:postgres/postgres.dart';

part 'pgmq.part.dart';

abstract class Pgmq {
  /// Create queue
  /// [queueName] : name of the queue
  static Future<Pgmq> createConnection(
      {required DatabaseConnection param, bool usePostgresql2 = true}) async {
    try {
      if (usePostgresql2) {
        return _Pgmp.fromPostgresql2Connection(
            connection: param.connectionUsingPostgresql2());
      }
      return _Pgmp.fromPostgresConnection(
          connection: await param.connectionUsingPostgres());
    } catch (e, stack) {
      print(stack);
      throw GenericPgmqException(
          message: 'Unable to connect to database\n${e.toString()}');
    }
  }

  Future<Queue> createQueue({required String queueName});
}
