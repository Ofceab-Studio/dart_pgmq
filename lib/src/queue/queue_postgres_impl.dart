part of 'queue.dart';

class _QueuePostgresImpl implements Queue {
  final Connection _connection;
  final String _queueName;
  Statement? _readStatement;
  Statement? _popStatement;
  Statement? _archiveStatement;
  Statement? _deleteStatement;

  final MessageParser _messageParser = MessageParser();

  @override
  final StreamController<Message> controller = StreamController.broadcast();

  _QueuePostgresImpl(this._connection, this._queueName);

  @override
  Future<int> archive(int messageID) async {
    final query = "SELECT pgmq.archive(\$1, \$2);";

    _archiveStatement ??= await _connection.prepare(Sql(query));
    final result = await _archiveStatement!.run([_queueName, messageID]);

    return result.affectedRows;
  }

  @override
  Future<int> delete(int messageID) async {
    final query = "SELECT pgmq.delete(\$1, \$2);";

    _deleteStatement ??= await _connection.prepare(Sql(query));
    final result = await _deleteStatement!.run([_queueName, messageID]);

    return result.affectedRows;
  }

  @override
  Future<void> dropQueue() async {
    final query = "SELECT pgmq.drop_queue(\$1);";

    final stmt = await _connection.prepare(Sql(query));
    await stmt.run([_queueName]);
  }

  @override
  Future<Message?> pop() async {
    final query = "SELECT pgmq.pop(\$1);";
    _popStatement ??= await _connection.prepare(Sql(query));
    final result = await _popStatement!.run([_queueName]);

    final decodedMessage = utf8.decode(
        (result.first.toColumnMap()['pop'] as UndecodedBytes).bytes,
        allowMalformed: true);
    return _messageParser.messageFromPull(json.decode(decodedMessage));
  }

  @override
  Stream<Message> pull(
      {required Duration duration, bool useReadMethod = true}) {
    Timer.periodic(duration, (_) async {
      final message = useReadMethod
          ? await read(visibilityTimeOut: duration)
          : [await pop()];
      if (message != null && message.isNotEmpty) {
        controller.add(message.first!);
      }
    });
    return controller.stream;
  }

  @override
  Future<List<Message>?> read(
      {int? maxReadNumber, Duration? visibilityTimeOut}) async {
    final vt = visibilityTimeOut ?? Duration(seconds: 10);
    return _read(vt, maxReadNumber ?? 1);
  }

  Future<List<Message>?> _read(Duration vt, int maxReadNumber) async {
    final query = "SELECT * FROM pgmq.read(\$1, \$2, \$3);";
    _readStatement ??= await _connection.prepare(Sql(query));
    final result = await _readStatement!
        .run([_queueName, vt.inMilliseconds, maxReadNumber]);

    return result
        .take(maxReadNumber)
        .map((msg) => _messageParser.messageFromRead(msg.toColumnMap()))
        .toList();
  }

  @override
  Future<int> send(Map<String, dynamic> payload) async {
    final query = "SELECT * from pgmq.send(\$1, \$2)";

    final result = await _connection
        .execute(query, parameters: [_queueName, json.encode(payload)]);
    return result.affectedRows;
  }

  @override
  Future<void> dispose() async {
    await controller.close();
  }

  @override
  Future<int> purgeQueue() {
    throw UnimplementedError();
  }
}
