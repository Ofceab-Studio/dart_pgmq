import 'pgmq_exception.dart';

typedef CanHaveError<T> = (PgmqException?, T?);
typedef OnRight<R, T> = R Function(T);
typedef OnLeft<T> = T Function(PgmqException);

extension CanHaveErrorExtension<T, R> on CanHaveError<T> {
  bool get isLeft {
    return this.$1 != null && this.$2 == null;
  }

  bool get isRight {
    return this.$1 == null && this.$2 != null;
  }

  fold({required OnRight<R, T> onRight, required OnLeft onLeft}) {
    if (isLeft) {
      return onLeft(this.$1!);
    }
    return onRight(this.$2 as T);
  }
}
