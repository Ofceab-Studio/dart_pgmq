// import 'package:dart_pgmq/src/exception/can_have_error.dart';
// import 'package:dart_pgmq/src/exception/pgmq_exception.dart';

// class ErrorCatcher {
//   static Future<CanHaveError<T>> tryCatch<T>(
//       Future<T> Function() function) async {
//     try {
//       return (null, await function());
//     } catch (e, stackTrack) {
//       print('${e.toString()}\n$stackTrack');
//       if (e is PgmqException) {
//         return (e, null);
//       }
//       return (GenericPgmqException(message: e.toString()), null);
//     }
//   }
// }
