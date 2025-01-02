import 'dart:async';

import 'package:dart_pgmq/dart_pgmq.dart';

Future<void> main() async {
  // Create a DatabaseConnection
  final databaseParam = DatabaseConnection(
    host: 'localhost',
    database: 'postgres',
    password: 'password',
    username: 'postgres',
    ssl: false,
    port: 5432,
  );

  // Create a connexion
  final pgmq = await Pgmq.createConnection(
      param: databaseParam,
      options: PoolConnectionOptions(
        connectionTimeout: Duration(seconds: 2),
        queryTimeout: Duration(seconds: 2),
        maxConnection: 3,
        maxLifetime: Duration(days: 1),
        onConnectionOpened: (connection) async {
          print('New connection opened ${connection.isOpen}');
        },
      ));
  // final pgmq1 = await Pgmq.createConnection(param: databaseParam);

  runZonedGuarded(
    () async {
      //  Create a queue
      final queue = await pgmq.createQueue(queueName: 'subscription_queue_1');

      final (pause, stream) =
          queue.pausablePull(duration: Duration(milliseconds: 500));

      stream.listen(
        (event) async {
          print('MessageID: ${event.messageID}\n ${event.payload}');
          await queue.delete(event.messageID);
        },
      );
    },
    (error, stack) {
      print('[[ $error\n$stack]]');
    },
  );
}
