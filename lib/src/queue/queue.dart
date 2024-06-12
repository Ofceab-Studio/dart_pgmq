import 'dart:async';
import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:postgresql2/postgresql.dart' as postgresql2;

part 'queue_postgres_impl.dart';
part 'queue_postgresql2_impl.dart';

abstract class Queue {
  StreamController<Map<dynamic, dynamic>> get controller;

  factory Queue.uingPostgresql2(
          postgresql2.Connection connection, String queueName) =>
      _QueuePostgresql2Impl(connection, queueName);

  factory Queue.uingPostgresql(Connection connection, String queueName) =>
      _QueuePostgresImpl(connection, queueName);

  /// Send message to the queue
  Future<int> send(Map<String, dynamic> payload);

  Future<Map<dynamic, dynamic>?> read(
      {int? messageID, Duration? visibilityTimeOut});

  /// Remove message from queue
  Future<Map<dynamic, dynamic>?> pop();

  /// [messageID] : archivre message id
  Future<int> archive(int messageID);

  /// [messageID] : message id
  Future<int> delete(int messageID);

  Future<void> dropQueue();

  Future<void> dispose();

  Stream<Map<dynamic, dynamic>> pull({required Duration duration});
}
