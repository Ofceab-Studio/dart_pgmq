/// An abstract class representing an exception thrown by the Pgmq package.
///
/// This class provides a common interface for all exceptions thrown by the Pgmq package.
abstract class PgmqException {
  /// The error message associated with the exception.
  String get message;

  /// Returns a string representation of the exception, which is the same as the [message] property.
  @override
  String toString() {
    return message;
  }
}

/// A generic exception class for the Pgmq package.
class GenericPgmqException implements PgmqException {
  /// The error message associated with the exception.
  @override
  final String message;

  /// Creates a new instance of [GenericPgmqException] with the specified error message.
  const GenericPgmqException({required this.message});

  /// Returns a string representation of the exception.
  @override
  String toString() => message;
}
