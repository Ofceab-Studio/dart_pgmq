import 'package:postgresql2/pool.dart' as postgresql2pool;
import 'package:postgresql2/postgresql.dart' as postgresql2;

class PoolConnectionOptions {
  int? minConnection;
  int? maxConnection;
  Duration? connectionTimeout;
  Duration? idleTimeout;
  Duration? establishTimeout;
  Duration? limitTimeout;
  Duration? maxLifetime;
  Duration? leakDetectionThreshold;
  Duration? startTimeout;
  Duration? stopTimeout;
  int? limitConnections;

  PoolConnectionOptions(
      {this.connectionTimeout,
      this.establishTimeout,
      this.idleTimeout,
      this.limitConnections,
      this.limitTimeout,
      this.maxConnection,
      this.startTimeout,
      this.stopTimeout,
      this.maxLifetime,
      this.leakDetectionThreshold,
      this.minConnection});
}

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
      PoolConnectionOptions poolConnectionOptions) async {
    final uri = _getDBUri(ssl);
    final pool = postgresql2pool.Pool(uri,
        connectionTimeout: poolConnectionOptions.connectionTimeout,
        establishTimeout: poolConnectionOptions.establishTimeout,
        limitConnections: poolConnectionOptions.limitConnections,
        idleTimeout: poolConnectionOptions.idleTimeout,
        leakDetectionThreshold: poolConnectionOptions.leakDetectionThreshold,
        startTimeout: poolConnectionOptions.startTimeout,
        stopTimeout: poolConnectionOptions.stopTimeout,
        maxLifetime: poolConnectionOptions.maxLifetime,
        limitTimeout: poolConnectionOptions.limitTimeout,
        minConnections: poolConnectionOptions.minConnection ?? 2,
        maxConnections: poolConnectionOptions.maxConnection ?? 5);
    await pool.start();
    return pool.connect;
  }

  /// Returns the `postgresql` connection URI based on the SSL configuration.
  String _getDBUri(bool ssl) => ssl
      ? 'postgres://$username:$password@$host:$port/$database?sslmode=require'
      : 'postgres://$username:$password@$host:$port/$database';
}
