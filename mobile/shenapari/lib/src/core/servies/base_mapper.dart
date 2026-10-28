
abstract class BaseMapper<T, R> {

  R mapperTo(T data);

  T mapperFrom(R data) => throw UnimplementedError();
}
