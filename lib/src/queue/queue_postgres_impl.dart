part of 'queue.dart';

/// An implementation of the [Queue] abstract class with [prostgres] package
/// for managing message queues
class _QueuePostgresImpl implements Queue {
  final Pool _connection;
  final String _queueName;

  static const _kDefaultTimeout = Duration(seconds: 7);

  @override
  final List<StreamController<Message>> controllers = [];

  _QueuePostgresImpl(this._connection, this._queueName);

  @override
  Future<int?> archive(int messageID, {Duration? timeout}) async {
    final query = "SELECT pgmq.archive(@queue,@msgID);";

    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await _withCancellation(
              connection,
              (cx) => cx.execute(Sql.named(query),
                  parameters: {'queue': _queueName, 'msgID': messageID}),
              timeout: timeout,
            );

            return result?.affectedRows;
          },
        );

        return result;
      },
    );
  }

  @override
  Future<int?> delete(int messageID, {Duration? timeout}) async {
    final query = "SELECT pgmq.delete(@queue::TEXT, @msgID::BIGINT);";

    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await _withCancellation(
                connection,
                (cx) => cx.execute(Sql.named(query),
                    parameters: {'queue': _queueName, 'msgID': messageID}),
                timeout: timeout);

            return result?.affectedRows;
          },
        );
        return result;
      },
    );
  }

  @override
  Future<void> dropQueue({Duration? timeout}) async {
    final query = "SELECT pgmq.drop_queue(@queue);";

    return ErrorCatcher.tryCatch(
      () async {
        await _connection.withConnection(
          (connection) async {
            await _withCancellation(
                connection,
                (cx) => cx.execute(Sql.named(query),
                    parameters: {'queue': _queueName}),
                timeout: timeout);
          },
        );
      },
    );
  }

  Future<T?> _withCancellation<T>(
      Connection connection, Future<T> Function(Connection) func,
      {Duration? timeout}) async {
    final cancellableOp = CancelableOperation.fromFuture(
      func(connection),
      onCancel: () async => await connection.close(),
    );
    final timer = Timer(
      timeout ?? _kDefaultTimeout,
      () async {
        if (!cancellableOp.isCompleted) {
          await cancellableOp.cancel();
        }
      },
    );

    final result = await cancellableOp.valueOrCancellation();
    await connection.close();
    timer.cancel();
    return result;
  }

  @override
  Future<Message?> pop({Duration? timeout}) async {
    final query = "SELECT row_to_json(pgmq.pop(@queue));";
    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            return await _withCancellation(
                connection,
                (cx) => cx.execute(
                      Sql.named(query),
                      parameters: {'queue': _queueName},
                    ),
                timeout: timeout);
          },
        );

        if (result == null || (result.isEmpty)) {
          return null;
        }

        return Message.fromJson(result.first.toColumnMap()['row_to_json']);
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

  Future<List<Message>?> _read(Duration vt, int maxReadNumber,
      {Duration? timeout}) async {
    final query = "SELECT * FROM pgmq.read(@queue,@vt,@maxReadNumber);";
    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await _withCancellation(
                connection,
                (cx) => cx.execute(Sql.named(query), parameters: {
                      'queue': _queueName,
                      'vt': vt.inSeconds,
                      'maxReadNumber': maxReadNumber
                    }),
                timeout: timeout);
            return result;
          },
        );

        if (result == null) {
          return null;
        }

        return result
            .take(maxReadNumber)
            .map((msg) => Message.fromJson(msg.toColumnMap()))
            .toList();
      },
    );
  }

  @override
  Future<int?> send(Map<String, dynamic> payload, {Duration? timeout}) async {
    final query = "SELECT * from pgmq.send(@queue,@payload)";

    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await _withCancellation(
                connection,
                (cx) => cx.execute(Sql.named(query), parameters: {
                      'queue': _queueName,
                      'payload': json.encode(payload)
                    }),
                timeout: timeout);
            return result?.affectedRows;
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
            final result = await _withCancellation(
                connection,
                (cx) => cx.execute(Sql.named(query),
                    parameters: {'queue': _queueName}));
            return result;
          },
        );

        if (result == null || (result.isEmpty)) {
          return null;
        }

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
      {required int messageID,
      required Duration duration,
      Duration? timeout}) async {
    final query = "select * from pgmq.set_vt(@queue,@msgID,@vt);";

    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection.withConnection(
          (connection) async {
            final result = await _withCancellation(
                connection,
                (cx) => cx.execute(Sql.named(query), parameters: {
                      'queue': _queueName,
                      'msgID': messageID,
                      'vt': duration.inSeconds
                    }),
                timeout: timeout);
            return result;
          },
        );

        if (result == null || (result.isEmpty)) {
          return null;
        }

        return Message.fromJson(result.first.toColumnMap());
      },
    );
  }
}
