import 'package:orm/orm.dart';
import 'package:postgres/postgres.dart';
import '../exception/pgmq_exception.dart';
import '../queue/queue.dart';
import 'database_connection.dart';

part 'pgmq.part.dart';

/// An abstract class that provides an interface for creating and managing
/// a `postgresql` message queues.
abstract class Pgmq {
  /// Creates a new connection to the `postgresql` database for managing message queues.
  ///
  /// The [param] parameter is an instance of [DatabaseConnection] that contains
  /// the necessary information for connecting to the `postgresql` database.
  ///
  /// Throws a [GenericPgmqException] if there is an error connecting to the database.
  static Future<Pgmq> createConnection(
      {required DatabaseConnection param,
      PoolConnectionOptions? options}) async {
    try {
      return _Pgmp._(pool: await param.connect(poolOptions: options));
    } catch (e, stack) {
      print(stack);
      throw GenericPgmqException(
          message: 'Unable to connect to database\n${e.toString()}');
    }
  }

  /// Creates a new connection using [Prisma].
  static Pgmq createConnectionUsingPrisma({
    required BasePrismaClient prismaClient,
  }) {
    try {
      return _PgmqPrisma._(prismaClient: prismaClient);
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

  Future<void> dispose();
}
