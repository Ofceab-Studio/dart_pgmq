## 2.1.0

- feat: Add advanced JSON filter support to `read` and `readWithPoll` methods
- feat: Introduce `Filter` class with fluent API for building conditional filters
  - Support for equality (`eq`), not-equal (`ne`), greater-than (`gt`), greater-than-or-equal (`gte`), less-than (`lt`), less-than-or-equal (`lte`), and exists (`exists`) operators
  - Type-safe filter builder that converts to pgmq JSON format automatically
- feat: Implement `readWithPoll` method for both PostgreSQL and Prisma implementations
- breaking: Change `conditional` parameter type from `Map<String, dynamic>?` to `Filter?` in `read` and `readWithPoll` methods
  - Migration: Replace `conditional: {'field': 'x', 'operator': '>', 'value': 1}` with `conditional: Filter.gt('x', 1)`
- docs: Update README with Filter API examples and usage patterns

## 2.0.0

- feat: Use postgres as client for pgmq
- feat: Improve performance by using connection pool.
- fix: Make `Queue` disposable.
- feat: Add cancellation on request execution.
- feat: Support Prisma as postgres database  client
- feat: Add fromJson and toJson on `Messsage`.

## 1.0.0

Initial version.

- feat: Includes the ability to create a `PgmqConnexion`.
- feat: Includes the ability to create, purge, drop a `Queue`.
- feat: Includes the ability to send, read, pop, archive, delete a `Message`.
- feat: Includes the ability to set a `vt` (visibility timeout).
