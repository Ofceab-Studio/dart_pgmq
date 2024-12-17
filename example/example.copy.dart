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
          connectionTimeout: Duration(seconds: 7),
          queryTimeout: Duration(seconds: 7),
          establishTimeout: Duration(seconds: 15),
          onConnectionOpened: (connection) async {
            print('New connection opened ${connection.isOpen}');
          },
          maxLifetime: Duration(days: 1),
          idleTimeout: Duration(hours: 1)));
  // final pgmq1 = await Pgmq.createConnection(param: databaseParam);

  runZonedGuarded(
    () async {
      //  Create a queue
      final queue =
          await pgmq.createQueue(queueName: 'orange_subscription_queue');

      final mtnqueue =
          await pgmq.createQueue(queueName: 'mtn_subscription_queue');

      final (pause, stream) =
          queue.pausablePull(duration: Duration(milliseconds: 500));

      final (pausemtn, streammtn) =
          mtnqueue.pausablePull(duration: Duration(milliseconds: 500));

      stream.listen(
        (event) async {
          print('MessageID: ${event.messageID}\n ${event.payload}');
          await queue.delete(event.messageID);
        },
      );

      streammtn.listen(
        (event) async {
          print('MTN MessageID: ${event.messageID}\n ${event.payload}');
          await mtnqueue.delete(event.messageID);
        },
      );

      pause.start();
      pausemtn.start();
    },
    (error, stack) {
      print(error);
    },
  );
}
