part of 'queue.dart';

/// An implementation of the [Queue] abstract class with [prostgres] package
/// for managing message queues
class _QueuePostgresImpl implements Queue {
  final Connection _connection;
  final String _queueName;
  Statement? _readStatement;
  Statement? _popStatement;
  Statement? _archiveStatement;
  Statement? _deleteStatement;
  Statement? _setVisibilityStatement;
  Statement? _purgeStatement;

  final MessageParser _messageParser = MessageParser();

  @override
  final List<StreamController<Message>> controllers = [];

  _QueuePostgresImpl(this._connection, this._queueName);

  @override
  Future<int?> archive(int messageID) async {
    final query = "SELECT pgmq.archive(\$1, \$2);";

    return ErrorCatcher.tryCatch(
      () async {
        _archiveStatement ??= await _connection.prepare(Sql(query));
        final result = await _archiveStatement!.run([_queueName, messageID]);

        return result.affectedRows;
      },
    );
  }

  @override
  Future<int?> delete(int messageID) async {
    final query = "SELECT pgmq.delete(\$1, \$2);";

    return ErrorCatcher.tryCatch(
      () async {
        _deleteStatement ??= await _connection.prepare(Sql(query));
        final result = await _deleteStatement!.run([_queueName, messageID]);

        return result.affectedRows;
      },
    );
  }

  @override
  Future<void> dropQueue() async {
    final query = "SELECT pgmq.drop_queue(\$1);";

    return ErrorCatcher.tryCatch(
      () async {
        final stmt = await _connection.prepare(Sql(query));
        await stmt.run([_queueName]);
      },
    );
  }

  @override
  Future<Message?> pop() async {
    final query = "SELECT row_to_json(pgmq.pop(\$1));";
    return ErrorCatcher.tryCatch(
      () async {
        _popStatement ??= await _connection.prepare(Sql(query));
        final result = await _popStatement!.run([_queueName]);
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
    final query = "SELECT * FROM pgmq.read(\$1, \$2, \$3);";
    return ErrorCatcher.tryCatch(
      () async {
        _readStatement ??= await _connection.prepare(Sql(query));
        final result = await _readStatement!
            .run([_queueName, vt.inMilliseconds, maxReadNumber]);

        return result
            .take(maxReadNumber)
            .map((msg) => _messageParser.messageFromRead(msg.toColumnMap()))
            .toList();
      },
    );
  }

  @override
  Future<int?> send(Map<String, dynamic> payload) async {
    final query = "SELECT * from pgmq.send(\$1, \$2)";

    return ErrorCatcher.tryCatch(
      () async {
        final result = await _connection
            .execute(query, parameters: [_queueName, json.encode(payload)]);
        return result.affectedRows;
      },
    );
  }

  @override
  Future<void> dispose() async {
    for (final controller in controllers) {
      await controller.close();
    }
  }

  @override
  Future<int?> purgeQueue() async {
    final query = "select * from pgmq.purge_queue(\$1);";
    return ErrorCatcher.tryCatch(
      () async {
        _purgeStatement ??= await _connection.prepare(Sql(query));
        final result = await _purgeStatement!.run([_queueName]);
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
      final message = useReadMethod
          ? await read(visibilityTimeOut: visibilityDuration)
          : [await pop()];
      if (message != null && message.isNotEmpty) {
        stream.add(message.first!);
      }
    });

    return (pausableTimer, stream.stream);
  }

  @override
  Future<Message?> setVisibilityTimeout(
      {required int messageID, required Duration duration}) async {
    final query = "select * from pgmq.set_vt(\$1,\$2,\$3);";

    return ErrorCatcher.tryCatch(
      () async {
        _setVisibilityStatement ??= await _connection.prepare(Sql(query));
        final result = await _setVisibilityStatement!
            .run([_queueName, messageID, duration.inSeconds]);
        return _messageParser.messageFromRead(result.first.toColumnMap());
      },
    );
  }
}
