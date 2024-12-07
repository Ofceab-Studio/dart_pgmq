// import 'package:dart_pgmq/src/exception/can_have_error.dart';
// import 'package:dart_pgmq/src/exception/pgmq_exception.dart';

class ErrorCatcher {
  static Future<T?> tryCatch<T>(Future<T?> Function() function) async {
    try {
      return await function();
    } catch (e, stackTrack) {
      print('${e.toString()}\n$stackTrack');
      return null;
    }
  }
}
