import 'dart:convert';

class Message {
  final int messageID;
  final int readCount;
  final DateTime? enqueueDate;
  final DateTime? visibleAt;
  final Map<dynamic, dynamic> payload;

  const Message(
      {required this.messageID,
      required this.readCount,
      required this.enqueueDate,
      required this.visibleAt,
      required this.payload});
}

class MessageParser {
  final RegExp _messageIDRegex = RegExp(r'\([0-9]+,');
  final RegExp _readCountRegex = RegExp(r',[0-9]+,');
  final RegExp _dateRegex = RegExp(
      r'"[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9\+]*');
  final RegExp _payloadRegex = RegExp(r'"{(.*)*}"');

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

  Message messageFromRead(Map<dynamic, dynamic> message) {
    return Message(
        messageID: message['msg_id'],
        readCount: message['read_ct'],
        enqueueDate: DateTime.tryParse(message['enqueued_at'].toString()),
        visibleAt: DateTime.tryParse(message['vt'].toString()),
        payload: message['message']);
  }
}
