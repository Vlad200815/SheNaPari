import 'package:flutter/cupertino.dart';

///
/// Base class for all use cases of domain layer.
/// The purpose of this class to make standard interface of communication between presentation
/// and data layer of the application.
///

sealed class UseCase {
  Future<void> dispose() => throw UnimplementedError();
}

///
/// Procedure [UseCase] which has no parameters and returns no result.
///
abstract class Procedure extends UseCase {
  Future<void> perform();
}

///
/// Procedure [UseCase] which has one parameter and returns no result.
///
abstract class Procedure1<@required P1> extends UseCase {
  Future<void> perform(P1 p1);
}

///
/// Procedure [UseCase] which has two parameter and returns no result.
///
abstract class Procedure2<@required P1, @required P2> extends UseCase {
  Future<void> perform(P1 p1, P2 p2);
}

///
/// Procedure [UseCase] which has three parameter and returns no result.
///
abstract class Procedure3<@required P1, @required P2, @required P3>
    extends UseCase {
  Future<void> perform(P1 p1, P2 p2, P3 p3);
}

///
/// Procedure [UseCase] which has four parameter and returns no result.
///
abstract class Procedure4<
  @required P1,
  @required P2,
  @required P3,
  @required P4
>
    extends UseCase {
  Future<void> perform(P1 p1, P2 p2, P3 p3, P4 p4);
}

///
/// Function [UseCase] which has no parameters and returns result.
///
abstract class Functions<R> extends UseCase {
  Future<R> perform();
}

///
/// Function [UseCase] which has one parameters and returns result.
///
abstract class Functions1<@required P1, R> extends UseCase {
  Future<R> perform(P1 p1);
}

///
/// Function [UseCase] which has two parameters and returns result.
///
abstract class Functions2<P1, P2, R> extends UseCase {
  Future<R> perform(P1 p1, P2 p2);
}

///
/// Function [UseCase] which has three parameters and returns result.
///
abstract class Functions3<P1, P2, P3, R> extends UseCase {
  Future<R> perform(P1 p1, P2 p2, P3 p3);
}

///
/// Function [UseCase] which has four parameters and returns result.
///
abstract class Functions4<P1, P2, P3, P4, R> extends UseCase {
  Future<R> perform(P1 p1, P2 p2, P3 p3, P4 p4);
}

abstract class Functions5<P1, P2, P3, P4, P5, R> extends UseCase {
  Future<R> perform(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5);
}

abstract class Functions8<P1, P2, P3, P4, P5, P6, P7, P8, R> extends UseCase {
  Future<R> perform({
    P1 sortBy,
    P2 sortOrder,
    P3 videoTypes,
    P4 videoGenres,
    P5 countryCodes,
    P6 startYear,
    P7 endYear,
    P8 pageToken,
  });
}

abstract class Any {}
