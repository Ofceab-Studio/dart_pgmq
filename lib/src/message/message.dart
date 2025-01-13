/// A [Message] class that contains information about a message.
class Message {
  /// The unique identifier of the message.
  final int messageID;

  /// The number of times the message has been read.
  final int readCount;

  /// The dateTime when the message was enqueued.
  final DateTime? enqueueDate;

  /// The dateTime when the message becomes visible in the queue.
  final DateTime? visibleAt;

  /// The payload data associated with the message.
  final Map<dynamic, dynamic> payload;

  /// Creates a new instance of [Message].
  const Message(
      {required this.messageID,
      required this.readCount,
      required this.enqueueDate,
      required this.visibleAt,
      required this.payload});
}

/// A utility class for parsing messages from a message queue.
class MessageParser {
  /// Parses a message from the result of a [read] operation.
  Message messageFromRead(Map<dynamic, dynamic> message) {
    return Message(
        messageID: int.parse(message['msg_id'].toString()),
        readCount: message['read_ct'],
        enqueueDate: DateTime.tryParse(message['enqueued_at'].toString()),
        visibleAt: DateTime.tryParse(message['vt'].toString()),
        payload: message['message']);
  }
}
