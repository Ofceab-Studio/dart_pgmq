## 1.0.0

Initial version.

- feat: Includes the ability to create a `PgmqConnexion`.
- feat: Includes the ability to create, purge, drop a `Queue`.
- feat: Includes the ability to send, read, pop, archive, delete a `Message`.
- feat: Includes the ability to set a `vt` (visibility timeout).

## 2.0.0

- feat: Improve performance by using connection pool.
- feat: Make `Queue` disposable.
- feat: Use postgres as client for pgmq
- feat: Add cancellation on request execution.
- feat: Add support of prisma as postgres database  client
- feat: Add fromJson and toJson on `Messsage`.