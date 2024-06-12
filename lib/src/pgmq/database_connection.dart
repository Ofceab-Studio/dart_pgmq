import 'package:postgres/postgres.dart';
import 'package:postgresql2/pool.dart' as postgresql2pool;
import 'package:postgresql2/postgresql.dart' as postgresql2;

class DatabaseConnection {
  final String host;
  final String database;
  final String password;
  final String username;
  final bool ssl;
  final int port;

  const DatabaseConnection(
      {required this.host,
      required this.database,
      required this.password,
      required this.username,
      required this.ssl,
      required this.port});

  Future<postgresql2.Connection> connectionUsingPostgresql2(
      {int? minConnection, int? maxConnection}) async {
    final uri = _getDBUri(ssl);
    final pool = postgresql2pool.Pool(uri,
        minConnections: minConnection ?? 2, maxConnections: maxConnection ?? 5);
    await pool.start();
    return pool.connect();
  }

  Future<Connection> connectionUsingPostgres(
      {int? minConnection, int? maxConnection}) async {
    return await Connection.open(
        Endpoint(
          host: host,
          database: database,
          username: username,
          password: password,
          port: port,
        ),
        settings: ConnectionSettings(
          sslMode: ssl ? SslMode.require : SslMode.disable,
        ));
  }

  String _getDBUri(bool ssl) => ssl
      ? 'postgres://$username:$password@$host:$port/$database?sslmode=require'
      : 'postgres://$username:$password@$host:$port/$database';
}
