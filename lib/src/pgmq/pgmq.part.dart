part of 'pgmq.dart';

/// An implementation of the [Pgmq] abstract class for creating and managing
/// a `postgresql` message queues.
class _Pgmp implements Pgmq {
  final Connection? connection;
  final Future<postgresql2.Connection>? postgresql2Connection;

  const _Pgmp._(
      {required this.connection, required this.postgresql2Connection});

  factory _Pgmp.fromPostgresConnection({required Connection connection}) =>
      _Pgmp._(connection: connection, postgresql2Connection: null);

  factory _Pgmp.fromPostgresql2Connection(
          {required Future<postgresql2.Connection> connection}) =>
      _Pgmp._(postgresql2Connection: connection, connection: null);

  @override
  Future<Queue> createQueue({required String queueName}) async {
    try {
      if (connection != null) {
        final query = 'SELECT pgmq.create(\$1);';
        final result =
            await connection!.execute(query, parameters: [queueName]);
        if (result.isNotEmpty) {
          return Queue.uingPostgresql(connection!, queueName);
        }
      } else if (postgresql2Connection != null) {
        final conn = await postgresql2Connection;
        final query = 'SELECT pgmq.create(@queue);';
        await conn!.execute(query, {'queue': queueName});
        return Queue.uingPostgresql2(conn, queueName);
      }

      throw GenericPgmqException(message: 'Unable to create a queue');
    } catch (e) {
      rethrow;
    }
  }
}
