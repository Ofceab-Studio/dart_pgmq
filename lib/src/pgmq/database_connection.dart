class DatabaseConnectionParam {
  final String host;
  final String database;
  final String password;
  final String username;
  final bool ssl;
  final int port;

  const DatabaseConnectionParam(
      {required this.host,
      required this.database,
      required this.password,
      required this.username,
      required this.ssl,
      required this.port});
}
