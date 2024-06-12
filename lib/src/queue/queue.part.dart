part of 'queue.dart';

class _Queue implements Queue {
  final Connection _connection;
  final String _queueName;
  Statement? _readStatement;
  Statement? _popStatement;
  Statement? _archiveStatement;
  Statement? _deleteStatement;
  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  _Queue(this._connection, this._queueName);

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
  Future<Map<String, dynamic>> pop() async {
    final query = "SELECT pgmq.pop(\$1);";

    _popStatement ??= await _connection.prepare(Sql(query));
    final result = await _popStatement!.run([_queueName]);
    print((result.first.toColumnMap()['pop'] as UndecodedBytes).asString);
    return result.first.toColumnMap();
  }

  @override
  Stream<Map<String, dynamic>> pull({required Duration duration}) {
    Timer.periodic(duration, (_) async => _controller.add(await pop()));
    return _controller.stream;
  }

  @override
  Future<Map<String, dynamic>> read(
      {int? messageID, Duration? visibilityTimeOut}) async {
    final vt = visibilityTimeOut ?? Duration(milliseconds: 10);
    if (messageID == null) {
      return await pop();
    }

    return _read(vt, messageID);
  }

  Future<Map<String, dynamic>> _read(Duration vt, int messageID) async {
    final query = "SELECT * FROM pgmq.read(\$1, \$2, \$3);";
    _readStatement ??= await _connection.prepare(Sql(query));
    final result =
        await _readStatement!.run([_queueName, vt.inMilliseconds, messageID]);

    return result.first.toColumnMap();
  }

  @override
  Future<int> send(Map<String, dynamic> payload) async {
    final query = "SELECT * from pgmq.send(\$1, \$2)";

    final result = await _connection
        .execute(query, parameters: [_queueName, json.encode(payload)]);
    return result.affectedRows;
  }
}
