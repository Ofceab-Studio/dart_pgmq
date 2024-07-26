part of 'pgmq.dart';

/// An implementation of the [Pgmq] abstract class for creating and managing
/// a `postgresql` message queues.
class _Pgmp implements Pgmq {
  final Pool pool;
  final Future<postgresql2.Connection> Function()? postgresql2Connection;

  const _Pgmp._({required this.postgresql2Connection, required this.pool});

  factory _Pgmp.fromPostgresql2Connection(
          {required Future<postgresql2.Connection> Function()? connection,
          required Pool pool}) =>
      _Pgmp._(postgresql2Connection: connection, pool: pool);

  @override
  Future<Queue> createQueue({required String queueName}) async {
    if (queueName.isEmpty) {
      throw GenericPgmqException(
          message: 'Queue should not be created with empty name');
    } else {
      try {
        if (postgresql2Connection != null) {
          final conn = await postgresql2Connection!();
          final query = 'SELECT pgmq.create(@queue);';
          await conn.execute(query, {'queue': queueName});
          return Queue.usingPostgresql2(postgresql2Connection!, queueName);
        }
        throw GenericPgmqException(message: 'Unable to create a queue');
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<void> dispose() async {
    await pool.stop();
  }
}
