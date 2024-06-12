import 'package:postgresql2/postgresql.dart' as postgresql2;
import '../exception/pgmq_exception.dart';
import '../queue/queue.dart';
import 'database_connection.dart';
import 'package:postgres/postgres.dart';

part 'pgmq.part.dart';

/// An abstract class that provides an interface for creating and managing
/// a `postgresql` message queues.
abstract class Pgmq {
  /// Creates a new connection to the `postgresql` database for managing message queues.
  ///
  /// The [param] parameter is an instance of [DatabaseConnection] that contains
  /// the necessary information for connecting to the `postgresql` database.
  ///
  /// The [usePostgresql2] parameter determines whether to use the `postgresql2`
  /// package or the `postgres` package for the database connection. By default,
  /// it uses the `postgresql2` package (recommended).
  ///
  /// Throws a [GenericPgmqException] if there is an error connecting to the database.
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

  /// Creates a new message queue with the specified name.
  ///
  /// The [queueName] parameter is the name of the queue to be created.
  Future<Queue> createQueue({required String queueName});
}
