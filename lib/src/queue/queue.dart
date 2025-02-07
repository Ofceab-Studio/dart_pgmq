import 'dart:async';
import 'dart:convert';
import 'package:dart_pgmq/src/exception/error_catcher.dart';
import 'package:dart_pgmq/src/message/message.dart';
import 'package:orm/orm.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:postgres/postgres.dart';
// ignore: depend_on_referenced_packages
import 'package:async/async.dart';

part 'queue_postgres_impl.dart';
part 'prisma_orm_postgres_impl.dart';

/// An abstract class that represents a `postgresql` message queue.
abstract class Queue {
  /// A [StreamController] that allows for listening to incoming messages from the queue.
  List<StreamController<Message>> get controllers;

  factory Queue.create(Pool pool, String queueName) =>
      _QueuePostgresImpl(pool, queueName);

  factory Queue.createUsingPrismaClient(
          BasePrismaClient prismaClient, String queueName) =>
      _PrismaOrmPostgresImpl(prismaClient, queueName);

  /// Sends a message to the queue with the specified payload.
  Future<int?> send(Map<String, dynamic> payload);

  ///Read 1 (by default) or more messages from a queue. The [visibilityTimeOut] specifies the amount of time in seconds
  ///that the message will be invisible to other consumers after reading.
  Future<List<Message>?> read(
      {int? maxReadNumber, Duration? visibilityTimeOut});

  /// Reads a single message from a queue and deletes it upon read.
  Future<Message?> pop();

  /// Archives a message in the queue.
  /// [messageID] : id of the message to archive
  Future<int?> archive(int messageID);

  /// Deletes a message from the queue.
  /// [messageID] : id of the message to  delete
  Future<int?> delete(int messageID);

  /// Purges all messages from the queue.
  Future<int?> purgeQueue();

  /// Drops the queue, effectively removing it from the database
  Future<void> dropQueue();

  /// Set visibility timeout of a message
  Future<Message?> setVisibilityTimeout(
      {required int messageID, required Duration duration});

  /// Dispose of any resources associated with the queue.
  Future<void> dispose();

  /// Continuously pulls messages from the queue for the specified duration.
  Stream<Message> pull(
      {required Duration duration,
      Duration? visibilityDuration,
      bool useReadMethod = true});

  // Continuously pulls messages from the queue using a repeating pausable timer for the specified duration.
  (PausableTimer, Stream<Message>) pausablePull(
      {required Duration duration,
      Duration? visibilityDuration,
      bool useReadMethod = true});
}
