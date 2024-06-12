import 'dart:async';
import 'dart:convert';

import 'package:dart_pgmq/src/message/message.dart';
import 'package:postgres/postgres.dart';
import 'package:postgresql2/postgresql.dart' as postgresql2;

part 'queue_postgres_impl.dart';
part 'queue_postgresql2_impl.dart';

abstract class Queue {
  List<StreamController<Message>> get controllers;

  /// Create a queue using Postgresql2 as postgres driver
  factory Queue.uingPostgresql2(
          postgresql2.Connection connection, String queueName) =>
      _QueuePostgresql2Impl(connection, queueName);

  /// [Disclamer]: this implementation using postgres library is not yet stable due to some
  /// an issue during database response encoding
  /// We recommended to use [Queue.uingPostgresql2(connection, queueName)] instead
  factory Queue.uingPostgresql(Connection connection, String queueName) =>
      _QueuePostgresImpl(connection, queueName);

  /// Send message to the queue
  Future<int> send(Map<String, dynamic> payload);

  ///Read 1 (by default) or more messages from a queue. The [visibilityTimeOut] specifies the amount of time in seconds
  ///that the message will be invisible to other consumers after reading.
  Future<List<Message>?> read(
      {int? maxReadNumber, Duration? visibilityTimeOut});

  /// Reads a single message from a queue and deletes it upon read.
  Future<Message?> pop();

  /// [messageID] : archivre message id
  Future<int> archive(int messageID);

  /// [messageID] : message id
  Future<int> delete(int messageID);

  /// Purge queue
  Future<int> purgeQueue();

  Future<void> dropQueue();

  Future<void> dispose();

  Stream<Message> pull({required Duration duration, bool useReadMethod = true});
}
