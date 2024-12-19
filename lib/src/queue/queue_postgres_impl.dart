part of 'queue.dart';

/// An implementation of the [Queue] abstract class with [prostgres] package
/// for managing message queues
class _QueuePostgresImpl implements Queue {
  final Pool _connection;
  final String _queueName;

  final MessageParser _messageParser = MessageParser();

  @override
  final List<StreamController<Message>> controllers = [];

  _QueuePostgresImpl(this._connection, this._queueName);

  @override
  Future<int?> archive(int messageID) async {
    final query = "SELECT pgmq.archive(@queue,@msgID);";

    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await connection.execute(Sql.named(query),
                parameters: {'queue': _queueName, 'msgID': messageID});
            await connection.close();
            return result.affectedRows;
          },
        );

        return result;
      },
    );
  }

  @override
  Future<int?> delete(int messageID) async {
    final query = "SELECT pgmq.delete(@queue::TEXT, @msgID::BIGINT);";

    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await connection.execute(Sql.named(query),
                parameters: {'queue': _queueName, 'msgID': messageID});
            await connection.close();
            return result.affectedRows;
          },
        );
        return result;
      },
    );
  }

  @override
  Future<void> dropQueue() async {
    final query = "SELECT pgmq.drop_queue(@queue);";

    return ErrorCatcher.tryCatch(
      () async {
        await _connection.withConnection(
          (connection) async {
            await connection
                .execute(Sql.named(query), parameters: {'queue': _queueName});
            await connection.close();
          },
        );
      },
    );
  }

  @override
  Future<Message?> pop() async {
    final query = "SELECT row_to_json(pgmq.pop(@queue));";
    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await connection
                .execute(Sql.named(query), parameters: {'queue': _queueName});
            await connection.close();
            return result;
          },
        );

        if (result.isEmpty) {
          return null;
        }

        return _messageParser
            .messageFromRead(result.first.toColumnMap()['row_to_json']);
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
      {int? maxReadNumber, Duration? visibilityTimeOut}) async {
    final vt = visibilityTimeOut ?? Duration(seconds: 10);
    return _read(vt, maxReadNumber ?? 1);
  }

  Future<List<Message>?> _read(Duration vt, int maxReadNumber) async {
    final query = "SELECT * FROM pgmq.read(@queue,@vt,@maxReadNumber);";
    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await connection.execute(Sql.named(query),
                parameters: {
                  'queue': _queueName,
                  'vt': vt.inSeconds,
                  'maxReadNumber': maxReadNumber
                });
            await connection.close();
            return result;
          },
        );

        return result
            .take(maxReadNumber)
            .map((msg) => _messageParser.messageFromRead(msg.toColumnMap()))
            .toList();
      },
    );
  }

  @override
  Future<int?> send(Map<String, dynamic> payload) async {
    final query = "SELECT * from pgmq.send(@queue,@payload)";

    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await connection.execute(Sql.named(query),
                parameters: {
                  'queue': _queueName,
                  'payload': json.encode(payload)
                });
            return result.affectedRows;
          },
        );
        return result;
      },
    );
  }

  @override
  Future<void> dispose() async {
    for (final controller in controllers) {
      await controller.close();
    }
    _connection.close();
  }

  @override
  Future<int?> purgeQueue() async {
    final query = "select * from pgmq.purge_queue(@queue);";
    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await connection
                .execute(Sql.named(query), parameters: {'queue': _queueName});
            await connection.close();
            return result;
          },
        );

        final v =
            int.parse(result.first.toColumnMap()['purge_queue'].toString());
        return v;
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
      {required int messageID, required Duration duration}) async {
    final query = "select * from pgmq.set_vt(@queue,@msgID,@vt);";

    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await connection.execute(Sql.named(query),
                parameters: {
                  'queue': _queueName,
                  'msgID': messageID,
                  'vt': duration.inSeconds
                });
            connection.close();
            return result;
          },
        );

        return _messageParser.messageFromRead(result.first.toColumnMap());
      },
    );
  }
}
