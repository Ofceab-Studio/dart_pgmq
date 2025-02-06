part of 'pgmq.dart';

/// An implementation of the [Pgmq] abstract class for creating and managing
/// a `postgresql` message queues.
class _Pgmp implements Pgmq {
  final Pool pool;

  const _Pgmp._({required this.pool});

  @override
  Future<Queue> createQueue({required String queueName}) async {
    if (queueName.isEmpty) {
      throw GenericPgmqException(
          message: 'Queue should not be created with empty name');
    } else {
      try {
        final query = 'SELECT pgmq.create(@queue);';
        final result = await pool
            .execute(Sql.named(query), parameters: {'queue': queueName});
        if (result.isNotEmpty) {
          return Queue.create(pool, queueName);
        }
        throw GenericPgmqException(message: 'Unable to create a queue');
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<void> dispose() async {
    await pool.close();
  }
}

/// An implementation of the [Pgmq] abstract class for creating and managing
/// a `postgresql` message queues with [Prisma].
class _PgmqPrisma implements Pgmq {
  final BasePrismaClient prismaClient;

  const _PgmqPrisma._({required this.prismaClient});

  @override
  Future<Queue> createQueue({required String queueName}) async {
    if (queueName.isEmpty) {
      throw GenericPgmqException(
          message: 'Queue should not be created with empty name');
    } else {
      try {
        final query = 'SELECT pgmq.create(\$1);';
        await prismaClient.$raw.execute(query, [queueName]);
        return Queue.createUsingPrismaClient(prismaClient, queueName);
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<void> dispose() async {
    await prismaClient.$disconnect();
  }
}
