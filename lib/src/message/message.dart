import 'dart:convert';

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
  final RegExp _messageIDRegex = RegExp(r'\([0-9]+,');
  final RegExp _readCountRegex = RegExp(r',[0-9]+,');
  final RegExp _dateRegex = RegExp(
      r'"[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9\+]*');
  final RegExp _payloadRegex = RegExp(r'"{(.*)*}"');

  /// Parses a message from the result of a [pop] operation.
  Message messageFromPull(Map<dynamic, dynamic> message) {
    final jsonStringify = message['pop'];

    final messageID = int.parse(_messageIDRegex
            .firstMatch(jsonStringify)?[0]
            .toString()
            .replaceFirst('(', '')
            .replaceFirst(',', '') ??
        '');
    final readCount = int.parse(_readCountRegex
            .firstMatch(jsonStringify)?[0]
            .toString()
            .replaceAll(',', '')
            .trim() ??
        '');

    final datesMatches = _dateRegex.allMatches(jsonStringify).toList();
    final enqueueDate = datesMatches.isNotEmpty
        ? DateTime.tryParse(
            datesMatches.first[0].toString().replaceFirst('"', ''))
        : null;

    final visibilityDate = datesMatches.isNotEmpty
        ? DateTime.tryParse(
            datesMatches.last[0].toString().replaceFirst('"', ''))
        : null;

    final sanitizedPayload = _payloadRegex
        .firstMatch(jsonStringify)?[0]
        ?.trim()
        .replaceFirst('"', '')
        .replaceAll('""', '"')
        .trim();
    final payload = json.decode(
        sanitizedPayload?.replaceFirst('"', '', sanitizedPayload.length - 1) ??
            '{}');

    return Message(
        messageID: messageID,
        readCount: readCount,
        enqueueDate: enqueueDate,
        visibleAt: visibilityDate,
        payload: payload);
  }

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
