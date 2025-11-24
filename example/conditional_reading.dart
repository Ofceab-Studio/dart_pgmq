import 'dart:async';
import 'dart:io';

import 'package:dart_pgmq/dart_pgmq.dart';
import 'package:dart_pgmq/src/conditional/conditional.dart';

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
      final queue = await pgmq.createQueue(queueName: 'cr-queue');

      // Send messages
      for (var i = 1; i <= 10; i++) {
        final payload = {'id': i, 'message': 'message $i', 'status': i%2==0? 'active':'inactive', 'expired': i<=4? true : false};
        await queue.send(payload);
      }

      // Read active messages
      print('active messages =>');
      final activeMessages = (await queue.read(maxReadNumber: 10, conditional: Conditional(field: 'status', operator: Operator.equal, value: 'active')));      
      for (final msg in activeMessages ?? <Message>[]) {
        print(msg.payload);
      }

      // Read un-expired messages
      print('un-expired messages =>');
      final unexpiredMessages = (await queue.read(maxReadNumber: 10, conditional: Conditional(field: 'expired', operator: Operator.equal, value: true)));
      for (final msg in unexpiredMessages ?? <Message>[]) {
        print(msg.payload);
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
