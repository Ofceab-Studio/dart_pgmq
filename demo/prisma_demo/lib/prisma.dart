import 'dart:async';

import 'package:dart_pgmq/dart_pgmq.dart';
import 'package:prisma/generated/prisma_client/client.dart';

Future<void> main() async {
  // Create a connexion
  final pgmq = Pgmq.createConnectionUsingPrisma(prismaClient: PrismaClient());
  // final pgmq1 = await Pgmq.createConnection(param: databaseParam);

  runZonedGuarded(
    () async {
      //  Create a queue
      final queue = await pgmq.createQueue(queueName: 'queue');
      print(await queue.purgeQueue());

      // final msg = await queue.read();
      // if (msg?.isNotEmpty ?? false) {
      //   await queue.delete(msg![0].messageID);
      // }
      final (pause, stream) =
          queue.pausablePull(duration: Duration(milliseconds: 500));

      stream.listen(
        (event) async {
          print('MessageID: ${event.messageID}\n ${event.payload}');
          final a = await queue.setVisibilityTimeout(
              messageID: event.messageID, duration: Duration(seconds: 10));
          print(a);
          // await queue.send({'hello': event.messageID});
        },
      );

      pause.start();
    },
    (error, stack) {
      print('[[ $error\n$stack]]');
    },
  );
}
