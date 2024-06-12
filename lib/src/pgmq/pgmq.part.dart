part of 'pgmq.dart';

class _Pgmp implements Pgmq {
  final Connection connection;

  const _Pgmp({required this.connection});

  @override
  Future<Queue> createQueue({required String queueName}) async {
    final query = 'SELECT pgmq.create(\$1);';
    final result = await connection.execute(query, parameters: [queueName]);
    if (result.isNotEmpty) {
      return Queue(connection, queueName);
    }
    throw GenericPgmqException(message: 'Unable to create a queue');
  }
}
