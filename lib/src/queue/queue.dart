import 'dart:async';
import 'dart:convert';
import 'package:dart_pgmq/src/message/message.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:postgres/postgres.dart';
import 'package:postgresql2/postgresql.dart' as postgresql2;

part 'queue_postgres_impl.dart';
part 'queue_postgresql2_impl.dart';

/// An abstract class that represents a `postgresql` message queue.
abstract class Queue {
  /// A [StreamController] that allows for listening to incoming messages from the queue.
  List<StreamController<Message>> get controllers;

  /// Creates a new instance of [Queue] using the [postgresql2] package as the `postgresql` driver.
  factory Queue.uingPostgresql2(
          postgresql2.Connection connection, String queueName) =>
      _QueuePostgresql2Impl(connection, queueName);

  /// Creates a new instance of [Queue] using the [postgres] package as the `postgresql` driver.
  ///
  /// [Disclamer]: this implementation using [postgres] library is not yet stable due to some
  /// issues during database response encoding
  /// We recommended using [Queue.uingPostgresql2(connection, queueName)] instead
  factory Queue.uingPostgresql(Connection connection, String queueName) =>
      _QueuePostgresImpl(connection, queueName);

  /// Sends a message to the queue with the specified payload.
  Future<int> send(Map<String, dynamic> payload);

  ///Read 1 (by default) or more messages from a queue. The [visibilityTimeOut] specifies the amount of time in seconds
  ///that the message will be invisible to other consumers after reading.
  Future<List<Message>?> read(
      {int? maxReadNumber, Duration? visibilityTimeOut});

  /// Reads a single message from a queue and deletes it upon read.
  Future<Message?> pop();

  /// Archives a message in the queue.
  /// [messageID] : id of the message to archive
  Future<int> archive(int messageID);

  /// Deletes a message from the queue.
  /// [messageID] : id of the message to  delete
  Future<int> delete(int messageID);

  /// Purges all messages from the queue.
  Future<int> purgeQueue();

  /// Drops the queue, effectively removing it from the database
  Future<void> dropQueue();

  /// Disposes of any resources associated with the queue.
  Future<void> dispose();

  /// Continuously pulls messages from the queue for the specified duration.
  Stream<Message> pull(
      {required Duration duration,
      Duration? visibilityDuration,
      bool useReadMethod = true});

  (PausableTimer, Stream<Message>) pausablePull(
      {required Duration duration,
      Duration? visibilityDuration,
      bool useReadMethod = true});
}
