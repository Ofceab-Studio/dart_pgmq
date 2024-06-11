import 'dart:async';
import 'dart:convert';

import 'package:postgres/postgres.dart';

part 'queue.part.dart';

abstract class Queue {
  factory Queue(Connection connection, String queueName) =>
      _Queue(connection, queueName);

  /// Send message to the queue
  Future<int> send(Map<String, dynamic> payload);

  Future<Map<String, dynamic>> read(
      {int? messageID, Duration? visibilityTimeOut});

  /// Remove message from queue
  Future<Map<String, dynamic>> pop();

  /// [messageID] : archivre message id
  Future<int> archive(int messageID);

  /// [messageID] : message id
  Future<int> delete(int messageID);

  Future<void> dropQueue();

  Stream<Map<String, dynamic>> pull({required Duration duration});
}
