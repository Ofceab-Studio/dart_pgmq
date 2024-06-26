part of 'queue.dart';

/// An implementation of the [Queue] abstract class with [postgresql2] package
/// for managing message queues
class _QueuePostgresql2Impl implements Queue {
  final postgresql2.Connection _connection;
  final String _queueName;
  final MessageParser _messageParser = MessageParser();

  @override
  final List<StreamController<Message>> controllers = [];

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
  Future<Message?> pop() async {
    final query = "SELECT pgmq.pop(@queue);";
    final data = await _connection.query(query, {'queue': _queueName}).toList();
    if (data.isNotEmpty) {
      return _messageParser.messageFromPull(data.first.toMap());
    }
    return null;
  }

  @override
  Stream<Message> pull(
      {required Duration duration,
      Duration? visibilityDuration,
      bool useReadMethod = true}) {
    final stream = StreamController<Message>();
    controllers.add(stream);
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
    final query = "SELECT * FROM pgmq.read(@queue, @vt, @maxReadNumber);";
    final values = {
      'queue': _queueName,
      'maxReadNumber': maxReadNumber,
      'vt': vt.inSeconds
    };

    final data = await _connection.query(query, values).toList();
    if (data.isNotEmpty) {
      return data
          .take(maxReadNumber)
          .map((msg) => _messageParser.messageFromRead(msg.toMap()))
          .toList();
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
    for (final controller in controllers) {
      await controller.close();
    }
  }

  @override
  Future<int> purgeQueue() async {
    final query = "select * from pgmq.purge_queue(@queue);";
    final values = {'queue': _queueName};

    final data = await _connection.query(query, values).toList();
    return int.parse(data.first.toMap()['purge_queue'].toString());
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
    final query = "select * from pgmq.set_vt(@queue,@messageID,@duration);";
    final values = {
      'queue': _queueName,
      'messageID': messageID,
      'duration': duration.inSeconds
    };

    final data = await _connection.query(query, values).toList();
    if (data.isNotEmpty) {
      return _messageParser.messageFromRead(data.first.toMap());
    }

    return null;
  }
}
