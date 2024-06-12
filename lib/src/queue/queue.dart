import 'dart:async';
import 'dart:convert';

import 'package:dart_pgmq/src/message/message.dart';
import 'package:postgres/postgres.dart';
import 'package:postgresql2/postgresql.dart' as postgresql2;

part 'queue_postgres_impl.dart';
part 'queue_postgresql2_impl.dart';

abstract class Queue {
  StreamController<Message> get controller;

  factory Queue.uingPostgresql2(
          postgresql2.Connection connection, String queueName) =>
      _QueuePostgresql2Impl(connection, queueName);

  factory Queue.uingPostgresql(Connection connection, String queueName) =>
      _QueuePostgresImpl(connection, queueName);

  /// Send message to the queue
  Future<int> send(Map<String, dynamic> payload);

  Future<Message?> read({int? messageID, Duration? visibilityTimeOut});

  /// Remove message from queue
  Future<Message?> pop();

  /// [messageID] : archivre message id
  Future<int> archive(int messageID);

  /// [messageID] : message id
  Future<int> delete(int messageID);

  Future<void> dropQueue();

  Future<void> dispose();

  Stream<Message> pull({required Duration duration});
}
