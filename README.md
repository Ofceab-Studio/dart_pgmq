## Dart PGMQ 
A dart client for Postgres Message Queue ([PGMQ](https://github.com/tembo-io/pgmq)).

### Usage

```bash
# Start a Postgres instance
docker run -d --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 quay.io/tembo/pg16-pgmq:latest
```

```bash
# Connect to Postgres
psql postgres://postgres:postgres@0.0.0.0:5432/postgres
```

```sql
-- create the pgmq schema
CREATE SCHEMA pgmq;
```

```sql
-- create the extension in the "pgmq" schema
CREATE EXTENSION pgmq;
```

### Then

```dart
// Create a database connection
final databaseParam = DatabaseConnection(
      host: 'localhost',
      database: 'postgres',
      password: 'postgres',
      username: 'postgres',
      ssl: false,
      port: 5432);
```

```dart
// Create a pgmq connection with DatabaseConnection param
final pgmq = await Pgmq.createConnection(param: databaseParam);
```

```dart
// Create a queue [queueName]
final queue = await pgmq.createQueue(queueName: queueName);
```

```dart
// Send a message
queue.send({"foo": "bar"});
```

```dart
// Read a message with visibilityTimeOut
queue.read(visibilityTimeOut: vt);
```

```dart
// Archive a message [messageID]
queue.archive(messageID);
```

```dart
// Delete a message [messageID]
queue.delete(messageID);
```

```dart
// Pull messages from queue with a specified polling duration
queue.pull(duration: duration);
```

```dart
// Pausable pull
final (pausableTimer, stream) = queue.pausablePull(duration: duration);
// Start the pausable pull
pausableTimer.start();
// Pause the pulling
pausableTimer.pause();
```

```dart
// Read a message from queue and delete it upon read
queue.pop();
```

```dart
// Purge all messages from queue
queue.purgeQueue();
```

```dart
// Drops the queue
queue.dropQueue();
```


## Supported Functionalities

- [x] [Sending Messages](https://tembo-io.github.io/pgmq/api/sql/functions/#sending-messages)
  - [x] [send](https://tembo-io.github.io/pgmq/api/sql/functions/#send)
  - [ ] [send_batch](https://tembo-io.github.io/pgmq/api/sql/functions/#send_batch)
- [ ] [Reading Messages](https://tembo-io.github.io/pgmq/api/sql/functions/#reading-messages)
  - [x] [read](https://tembo-io.github.io/pgmq/api/sql/functions/#read)
  - [ ] [read_with_poll](https://tembo-io.github.io/pgmq/api/sql/functions/#read_with_poll)
  - [x] [pop](https://tembo-io.github.io/pgmq/api/sql/functions/#pop)
- [x] [Deleting/Archiving Messages](https://tembo-io.github.io/pgmq/api/sql/functions/#deletingarchiving-messages)
  - [x] [delete (single)](https://tembo-io.github.io/pgmq/api/sql/functions/#delete-single)
  - [ ] [delete (batch)](https://tembo-io.github.io/pgmq/api/sql/functions/#delete-batch)
  - [x] [purge_queue](https://tembo-io.github.io/pgmq/api/sql/functions/#purge_queue)
  - [x] [archive (single)](https://tembo-io.github.io/pgmq/api/sql/functions/#archive-single)
  - [ ] [archive (batch)](https://tembo-io.github.io/pgmq/api/sql/functions/#archive-batch)
- [ ] [Queue Management](https://tembo-io.github.io/pgmq/api/sql/functions/#queue-management)
  - [x] [create](https://tembo-io.github.io/pgmq/api/sql/functions/#create)
  - [ ] [create_partitioned](https://tembo-io.github.io/pgmq/api/sql/functions/#create_partitioned)
  - [ ] [create_unlogged](https://tembo-io.github.io/pgmq/api/sql/functions/#create_unlogged)
  - [ ] [detach_archive](https://tembo-io.github.io/pgmq/api/sql/functions/#detach_archive)
  - [x] [drop_queue](https://tembo-io.github.io/pgmq/api/sql/functions/#drop_queue)
- [x] [Utilities](https://tembo-io.github.io/pgmq/api/sql/functions/#utilities)
  - [x] [set_vt](https://tembo-io.github.io/pgmq/api/sql/functions/#set_vt)
  - [ ] [list_queues](https://tembo-io.github.io/pgmq/api/sql/functions/#list_queues)
  - [ ] [metrics](https://tembo-io.github.io/pgmq/api/sql/functions/#metrics)
  - [ ] [metrics_all](https://tembo-io.github.io/pgmq/api/sql/functions/#metrics_all)

## Customs Features 
- [x] Pausable Queue
