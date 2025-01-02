import 'package:postgres/postgres.dart' as postgres;

class PoolConnectionOptions {
  /// Minimum number of connections. When the pool is started this is the number of connections
  /// that will initially be started. The pool will ensure that this number of connections
  /// is always running. In typical production settings,
  /// this should be set to be the same size as maxConnections.
  /// Defaults to 5.

  /// Maximum number of connections.
  /// The pool will not exceed this number of database connections.
  /// Defaults to 10.
  int? maxConnection;

  /// When client code calls Pool.connect(),
  /// and a connection does not become available within this time, an error is returned.
  /// Defaults to 30 seconds.
  Duration? connectionTimeout;

  /// When the pool wants to establish a new database connection
  /// and it is not possible to complete within
  /// this time then a warning will be logged.
  /// Defaults to 30 seconds.
  Duration? establishTimeout;

  Duration? maxLifetime;

  Duration queryTimeout;

  Future<void> Function(postgres.Connection)? onConnectionOpened;

  /// Pool Connection Configuration
  PoolConnectionOptions({
    this.connectionTimeout = const Duration(minutes: 1),
    this.onConnectionOpened,
    this.maxLifetime = const Duration(days: 1),
    this.queryTimeout = const Duration(seconds: 1),
    this.maxConnection = 6,
  });
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

  /// You can specify (optionally) the [minConnection] and [maxConnection] parameters
  /// to configure the connection pool.
  Future<postgres.Pool> connect({PoolConnectionOptions? poolOptions}) async {
    final pool = postgres.Pool.withEndpoints(
      [
        postgres.Endpoint(
          host: host,
          database: database,
          username: username,
          password: password,
          port: port,
        )
      ],
      settings: postgres.PoolSettings(
          sslMode: ssl ? postgres.SslMode.require : postgres.SslMode.disable,
          queryTimeout: poolOptions?.queryTimeout,
          connectTimeout: poolOptions?.connectionTimeout,
          maxConnectionCount: poolOptions?.maxConnection,
          onOpen: poolOptions?.onConnectionOpened,
          queryMode: postgres.QueryMode.extended,
          maxConnectionAge: poolOptions?.maxLifetime),
    );

    return pool;
  }
}
