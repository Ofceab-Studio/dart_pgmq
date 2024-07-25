import 'package:postgres/postgres.dart';
import 'package:postgresql2/pool.dart' as postgresql2pool;
import 'package:postgresql2/postgresql.dart' as postgresql2;

/// The [DatabaseConnection] class provides methods to establish a connection
/// to a `postgresql` database.
class DatabaseConnection {
  /// The hostname of the database server.
  final String host;

  /// The name of the database to connect to.
  final String database;

  /// The password for the database user.
  final String password;

  /// The username for the database connection.
  final String username;

  /// Whether to use SSL for the database connection.
  final bool ssl;

  /// The port number of the database server.
  final int port;

  /// Creates a new instance of [DatabaseConnection].
  const DatabaseConnection(
      {required this.host,
      required this.database,
      required this.password,
      required this.username,
      required this.ssl,
      required this.port});

  /// Establishes a connection to the `postgresql` database using the [postgresql2] package.
  ///
  /// You can specify (optionally) the [minConnection] and [maxConnection] parameters
  /// to configure the connection pool.
  Future<Future<postgresql2.Connection> Function()> connectionUsingPostgresql2(
      {int? minConnection,
      int? maxConnection,
      Duration? connectionTimeout,
      Duration? establishTimeout,
      Duration? limitTimeout,
      int? limitConnections}) async {
    final uri = _getDBUri(ssl);
    final pool = postgresql2pool.Pool(uri,
        connectionTimeout: connectionTimeout,
        establishTimeout: establishTimeout,
        limitConnections: limitConnections,
        limitTimeout: limitTimeout,
        minConnections: minConnection ?? 2,
        maxConnections: maxConnection ?? 5);
    await pool.start();
    return pool.connect;
  }

  /// Establishes a connection to the `postgresql` database using the [postgres] package.
  ///
  /// You can specify (optionally) the [minConnection] and [maxConnection] parameters
  /// to configure the connection pool.
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

  /// Returns the `postgresql` connection URI based on the SSL configuration.
  String _getDBUri(bool ssl) => ssl
      ? 'postgres://$username:$password@$host:$port/$database?sslmode=require'
      : 'postgres://$username:$password@$host:$port/$database';
}
