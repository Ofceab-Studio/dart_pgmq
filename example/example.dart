import 'dart:async';

import 'package:dart_pgmq/dart_pgmq.dart';

Future<void> main() async {
  // Create a DatabaseConnection
  runZonedGuarded(
    () async {
      final databaseParam = DatabaseConnection(
          host: 'localhost',
          database: 'postgres',
          password: 'password',
          username: 'postgres',
          ssl: false,
          port: 5432);

      // Create a connexion
      final pgmq = await Pgmq.createConnection(
          param: databaseParam,
          options:
              PoolConnectionOptions(queryTimeout: Duration(milliseconds: 500)));

      //  Create a queue
      final queue = await pgmq.createQueue(queueName: 'queueName');

      final (s, a) = queue.pausablePull(duration: Duration(seconds: 2));

      s.start();

      a.listen(
        (event) {
          final t = Stopwatch()..start();
          print(event);
          print(t.elapsedMilliseconds);
          t.stop();
        },
      );
      // // Send message
      for (var i = 1; i <= 10; i++) {
        // await Future.delayed(Duration(seconds: 3));
        final payload = {
          'id': i,
          'message':
              'message $i message $i message $i message $i message $i message $i message $i'
        };
        final stop = Stopwatch()..start();
        await queue.send(payload);
        print(stop.elapsedMilliseconds);
        stop.stop();
      }

      // // Read message
      // final data = (await queue.read(maxReadNumber: 5));
      // for (final msg in data ?? <Message>[]) {
      //   print(msg.payload);
      //   final seMessage = await queue.setVisibilityTimeout(
      //       messageID: msg.messageID, duration: Duration(seconds: 10));
      //   print('From set ${seMessage?.messageID}\n${seMessage?.payload}');
      // }

      // for (var i = 0; i < 7; i++) {
      //   final a = await queue.pop();
      //   print(a);
      // }

      // // Purge queue
      // await queue.purgeQueue();
    },
    (error, stack) {
      print(error);
    },
  );
}
