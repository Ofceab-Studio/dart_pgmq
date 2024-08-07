import 'package:postgresql2/pool.dart' as postgresql2pool;
import 'package:postgresql2/pool.dart';
import 'package:postgresql2/postgresql.dart' as postgresql2;

class PoolConnectionOptions {
  /// Minimum number of connections. When the pool is started this is the number of connections
  /// that will initially be started. The pool will ensure that this number of connections
  /// is always running. In typical production settings,
  /// this should be set to be the same size as maxConnections.
  /// Defaults to 5.
  int? minConnection;

  /// Maximum number of connections.
  /// The pool will not exceed this number of database connections.
  /// Defaults to 10.
  int? maxConnection;

  /// When client code calls Pool.connect(),
  /// and a connection does not become available within this time, an error is returned.
  /// Defaults to 30 seconds.
  Duration? connectionTimeout;

  /// If a connection has not been used for this ammount of time
  /// and there are more than the minimum number of connections in the pool,
  /// then this connection will be closed.
  /// Defaults to 10 minutes.
  Duration? idleTimeout;

  /// When the pool wants to establish a new database connection
  /// and it is not possible to complete within
  /// this time then a warning will be logged.
  /// Defaults to 30 seconds.
  Duration? establishTimeout;

  /// If the number of connections is more than limitConnections,
  /// the establishing of new connections will be
  /// slowed down by waiting the duration specified in limitTimeout.
  /// Default: 700ms.
  Duration? limitTimeout;

  /// At the time that a connection is released, if it is older than
  /// this time it will be closed.
  /// Defaults to 30 minutes.
  Duration? maxLifetime;

  /// If a connection is not returned to the pool within this time
  /// after being obtained by pool.connect(), the a warning message will be logged.
  /// Defaults to null, off by default.
  ///
  /// This setting is useful for tracking down code which leaks
  /// connections by forgetting to call Connection.close() on them.
  Duration? leakDetectionThreshold;

  /// If the pool cannot start within this time then return an error.
  /// Defaults to 30 seconds.
  Duration? startTimeout;

  /// If when stopping connections are not returned to the pool within this time,
  /// then they will be forefully closed.
  /// Defaults to 30 seconds.
  Duration? stopTimeout;

  /// A soft limit to keep the number of connections below it.
  /// If number of connections exceeds limitConnections, they'll be removed from
  ///  the pool as soon as possible (about a minute after released).
  int? limitConnections;

  /// Perform a simple query to check if a connection is
  /// still valid before returning a connection from pool.connect(). Default is
  /// true.
  bool testConnections;

  /// Once the entire pool is full of leaked
  /// connections, close them all and restart the minimum number of connections.
  /// Defaults to false. This must be used in combination with the leak
  /// detection threshold setting.
  bool restartIfAllConnectionsLeaked;

  /// Pool Connection Configuration
  PoolConnectionOptions(
      {this.connectionTimeout,
      this.establishTimeout,
      this.idleTimeout,
      this.limitConnections,
      this.limitTimeout,
      this.maxConnection,
      this.startTimeout,
      this.stopTimeout,
      this.restartIfAllConnectionsLeaked = false,
      this.testConnections = true,
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
  Future<(Pool, Future<postgresql2.Connection> Function())>
      connectionUsingPostgresql2(
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
        testConnections: poolConnectionOptions.testConnections,
        minConnections: poolConnectionOptions.minConnection ?? 2,
        restartIfAllConnectionsLeaked:
            poolConnectionOptions.restartIfAllConnectionsLeaked,
        maxConnections: poolConnectionOptions.maxConnection ?? 5);
    await pool.start();
    pool.messages.listen((event) {
      print(
          "Pool connection number Busy: ${pool.busyConnectionCount}, Pooled: ${pool.pooledConnectionCount}, wait queue ${pool.waitQueueLength}, Full cnnection: ${pool.connections.length}");
      print(
          "From pool ${event.connectionName} message:${event.message} isError: ${event.isError}");
    });
    return (pool, pool.connect);
  }

  /// Returns the `postgresql` connection URI based on the SSL configuration.
  String _getDBUri(bool ssl) => ssl
      ? 'postgres://$username:$password@$host:$port/$database?sslmode=require'
      : 'postgres://$username:$password@$host:$port/$database';
}
