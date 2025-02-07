import 'dart:async';
import 'dart:io';

import 'package:dart_pgmq/dart_pgmq.dart';

Future<void> main() async {
  // Create a DatabaseConnection
  runZonedGuarded(
    () async {
      final databaseParam = DatabaseConnection(
          host: 'localhost',
          database: 'postgres',
          password: 'postgres',
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

      final (pausableTimer, stream) =
          queue.pausablePull(duration: Duration(seconds: 2));

      pausableTimer.start();

      stream.listen(
        (event) {
          final t = Stopwatch()..start();
          print(event);
          print(t.elapsedMilliseconds);
          t.stop();
        },
      );

      // Send messages
      for (var i = 1; i <= 10; i++) {
        final payload = {'id': i, 'message': 'message $i'};
        await queue.send(payload);
      }

      // Read messages
      final data = (await queue.read(maxReadNumber: 5));
      for (final msg in data ?? <Message>[]) {
        print(msg.payload);
        await queue.setVisibilityTimeout(
            messageID: msg.messageID, duration: Duration(seconds: 10));
      }

      // Pop messages
      for (var i = 0; i < 5; i++) {
        await queue.pop();
      }

      // Purge the queue
      await queue.purgeQueue();

      // Drop the queue
      await queue.dropQueue();
      exit(0);
    },
    (error, stack) {
      print(error);
    },
  );
}
