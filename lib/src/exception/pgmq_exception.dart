abstract class PgmqException {
  String get message;
  @override
  String toString() {
    return message;
  }
}

class GenericPgmqException implements PgmqException {
  @override
  final String message;
  const GenericPgmqException({required this.message});
  @override
  String toString() => message;
}
