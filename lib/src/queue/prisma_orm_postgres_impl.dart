part of 'queue.dart';

/// An implementation of the [Queue] abstract class with [prostgres] package
/// for managing message queues
class _PrismaOrmPostgresImpl implements Queue {
  final String _queueName;
  final BasePrismaClient _prismaClient;

  final MessageParser _messageParser = MessageParser();

  @override
  final List<StreamController<Message>> controllers = [];

  _PrismaOrmPostgresImpl(this._prismaClient, this._queueName);

  @override
  Future<int?> archive(int messageID, {Duration? timeout}) async {
    final query = "SELECT pgmq.archive(\$1,\$2);";

    return ErrorCatcher.tryCatch(
      () async {
        final result =
            await _prismaClient.$raw.execute(query, [_queueName, messageID]);
        return result;
      },
    );
  }

  @override
  Future<int?> delete(int messageID, {Duration? timeout}) async {
    final query = "SELECT pgmq.delete(\$1::TEXT, \$2::BIGINT);";

    return ErrorCatcher.tryCatch(
      () async {
        final result =
            await _prismaClient.$raw.execute(query, [_queueName, messageID]);
        return result;
      },
    );
  }

  @override
  Future<void> dropQueue({Duration? timeout}) async {
    final query = "SELECT pgmq.drop_queue(\$1::TEXT);";

    return ErrorCatcher.tryCatch(
      () async {
        await _prismaClient.$raw.execute(query, [_queueName]);
      },
    );
  }

  @override
  Future<Message?> pop({Duration? timeout}) async {
    final query = "SELECT row_to_json(pgmq.pop(\$1));";
    return ErrorCatcher.tryCatch(
      () async {
        final result = await _prismaClient.$raw.query(query, [_queueName]);
        if (result.isEmpty) {
          return null;
        }

        return _messageParser.messageFromRead(
            result.first['row_to_json'] as Map<dynamic, dynamic>);
      },
    );
  }

  @override
  Stream<Message> pull(
      {required Duration duration,
      Duration? visibilityDuration,
      bool useReadMethod = true}) {
    final stream = StreamController<Message>();
    Timer.periodic(duration, (_) async {
      final message = useReadMethod
          ? await read(visibilityTimeOut: visibilityDuration)
          : [await pop()];
      if (message != null && message.isNotEmpty) {
        stream.add(message.first!);
      }
    });
    return stream.stream;
  }

  @override
  Future<List<Message>?> read(
      {int? maxReadNumber,
      Duration? visibilityTimeOut,
      Duration? timeout}) async {
    final vt = visibilityTimeOut ?? Duration(seconds: 10);
    return _read(vt, maxReadNumber ?? 1);
  }

  Future<List<Message>?> _read(
    Duration vt,
    int maxReadNumber,
  ) async {
    final query =
        "SELECT * FROM pgmq.read(\$1::TEXT,\$2::INTEGER,\$3::INTEGER);";
    return ErrorCatcher.tryCatch(
      () async {
        final result = await _prismaClient.$raw
            .query(query, [_queueName, vt.inSeconds, maxReadNumber]);

        if (result.isEmpty) {
          return null;
        }

        return result
            .take(maxReadNumber)
            .map((msg) => _messageParser.messageFromRead(msg))
            .toList();
      },
    );
  }

  @override
  Future<int?> send(Map<String, dynamic> payload, {Duration? timeout}) async {
    final query = "SELECT * from pgmq.send(\$1::TEXT,\$2::jsonb)";

    return ErrorCatcher.tryCatch(
      () async {
        final result = await _prismaClient.$raw
            .execute(query, [_queueName, json.encode(payload)]);
        return result;
      },
    );
  }

  @override
  Future<void> dispose() async {
    for (final controller in controllers) {
      await controller.close();
    }
    await _prismaClient.$disconnect();
  }

  @override
  Future<int?> purgeQueue() async {
    final query = "select * from pgmq.purge_queue(\$1);";
    return ErrorCatcher.tryCatch(
      () async {
        final result = await _prismaClient.$raw.execute(query, [_queueName]);
        return result;
      },
    );
  }

  @override
  (PausableTimer, Stream<Message>) pausablePull(
      {required Duration duration,
      Duration? visibilityDuration,
      bool useReadMethod = true}) {
    final stream = StreamController<Message>();
    controllers.add(stream);

    final pausableTimer = PausableTimer.periodic(duration, () async {
      List<Message> messages = [];
      if (useReadMethod) {
        final msg = await read(visibilityTimeOut: visibilityDuration);
        messages = msg ?? <Message>[];
      } else {
        final msg = await pop();
        messages = msg != null ? [msg] : <Message>[];
      }
      if (messages.isNotEmpty) {
        stream.add(messages.first);
      }
    });

    return (pausableTimer, stream.stream);
  }

  @override
  Future<Message?> setVisibilityTimeout(
      {required int messageID,
      required Duration duration,
      Duration? timeout}) async {
    final query =
        "select * from pgmq.set_vt(\$1::TEXT,\$2::BIGINT,\$3::INTEGER);";

    return ErrorCatcher.tryCatch(
      () async {
        final result = await _prismaClient.$raw
            .query(query, [_queueName, messageID, duration.inSeconds]);

        if (result.isEmpty) {
          return null;
        }

        return _messageParser.messageFromRead(result.first);
      },
    );
  }
}
