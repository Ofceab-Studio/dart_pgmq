part of 'queue.dart';

class _QueuePostgresql2Impl implements Queue {
  final postgresql2.Connection _connection;
  final String _queueName;

  @override
  final StreamController<Map<dynamic, dynamic>> controller =
      StreamController.broadcast();

  _QueuePostgresql2Impl(this._connection, this._queueName);

  @override
  Future<int> archive(int messageID) async {
    final query = "SELECT pgmq.archive(@queue,@messageID);";

    final values = {'queue': _queueName, 'messageID': messageID};
    final index = await _connection.execute(query, values);
    return index;
  }

  @override
  Future<int> delete(int messageID) async {
    final query = "SELECT pgmq.delete(@queue,@messageID);";
    final values = {'queue': _queueName, 'messageID': messageID};

    final index = await _connection.execute(query, values);
    return index;
  }

  @override
  Future<void> dropQueue() async {
    final query = "SELECT pgmq.drop_queue(@queue);";

    final values = {'queue': _queueName};
    await _connection.execute(query, values);
  }

  @override
  Future<Map<dynamic, dynamic>?> pop() async {
    final query = "SELECT pgmq.pop(@a);";
    final data = await _connection.query(query, {'a': _queueName}).toList();
    if (data.isNotEmpty) {
      return data.first.toMap();
    }
    return null;
  }

  @override
  Stream<Map<dynamic, dynamic>> pull({required Duration duration}) {
    Timer.periodic(duration, (_) async {
      final message = await pop();
      if (message != null) {
        controller.add(message);
      }
    });
    return controller.stream;
  }

  @override
  Future<Map<dynamic, dynamic>?> read(
      {int? messageID, Duration? visibilityTimeOut}) async {
    final vt = visibilityTimeOut ?? Duration(seconds: 10);
    if (messageID == null) {
      return await pop();
    }

    return _read(vt, messageID);
  }

  Future<Map<dynamic, dynamic>?> _read(Duration vt, int messageID) async {
    final query = "SELECT * FROM pgmq.read(@queue, @vt, @messageID);";
    final values = {
      'queue': _queueName,
      'messageID': messageID,
      'vt': vt.inMilliseconds
    };

    final data = await _connection.query(query, values).toList();
    if (data.isNotEmpty) {
      return data.first.toMap();
    }
    return null;
  }

  @override
  Future<int> send(Map<String, dynamic> payload) async {
    final query = "SELECT * from pgmq.send(@queue, @payload)";
    final values = {'queue': _queueName, 'payload': payload};

    final id = await _connection.execute(query, values);
    return id;
  }

  @override
  Future<void> dispose() async {
    await controller.close();
  }
}
