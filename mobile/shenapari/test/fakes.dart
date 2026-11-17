import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/features/auth/domain/auth_repository.dart';
import 'package:shenapari/features/auth/domain/entities/sign_in.dart';
import 'package:shenapari/features/menu/domain/entities/break_slot.dart';
import 'package:shenapari/features/menu/domain/entities/canteen.dart';
import 'package:shenapari/features/menu/domain/entities/category.dart';
import 'package:shenapari/features/menu/domain/entities/dish.dart';
import 'package:shenapari/features/menu/domain/menu_repository.dart';
import 'package:shenapari/features/profile/domain/entities/user.dart';
import 'package:shenapari/features/profile/domain/profile_repository.dart';

/// Accepts the code [validCode]; a number in [knownPhones] is a returning
/// customer, any other is new. Answers like the real backend.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.knownPhones = const {}});

  static const validCode = '123456';
  final Set<String> knownPhones;
  int logoutCalls = 0;

  @override
  Future<Result<void>> requestCode({required String phone}) async =>
      const Ok(null);

  @override
  Future<Result<SignIn>> verifyCode({
    required String phone,
    required String code,
  }) async {
    if (code != validCode) {
      return const Err(
        ValidationFailure(
          'Невірний або прострочений код',
          code: 'auth.invalid_code',
        ),
      );
    }
    return Ok(
      SignIn(
        tokens: const AuthTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
        ),
        isNewUser: !knownPhones.contains(phone),
      ),
    );
  }

  @override
  Future<Result<void>> logout({required String refreshToken}) async {
    logoutCalls++;
    return const Ok(null);
  }
}

class FakeProfileRepository implements ProfileRepository {
  String? savedName;
  int deleteCalls = 0;

  /// When set, deleting fails with it (like an active order on the server).
  Failure? deleteFailure;

  @override
  Future<Result<void>> deleteAccount() async {
    deleteCalls++;
    final failure = deleteFailure;
    return failure == null ? const Ok(null) : Err(failure);
  }

  @override
  Future<Result<User>> getMe() async =>
      Ok(User(id: '1', role: UserRole.customer, name: savedName));

  @override
  Future<Result<User>> updateName(String name) async {
    savedName = name;
    return Ok(User(id: '1', role: UserRole.customer, name: name));
  }
}

/// One category with one dish, no photos (widget tests have no network).
class FakeMenuRepository implements MenuRepository {
  @override
  Future<Result<Canteen>> getCanteen() async =>
      const Ok(Canteen(name: 'Їдальня №1', isAcceptingOrders: true));

  @override
  Future<Result<List<Category>>> getCategories() async =>
      const Ok([Category(id: 1, name: 'Бургери')]);

  @override
  Future<Result<List<Dish>>> getDishes() async => const Ok([
    Dish(
      id: 10,
      categoryId: 1,
      name: 'Чізбургер',
      priceKopecks: 8500,
      weightG: 250,
      kcal: 540,
    ),
  ]);

  @override
  Future<Result<Dish>> getDish(int id) async {
    final dishes = (await getDishes() as Ok<List<Dish>>).value;
    for (final dish in dishes) {
      if (dish.id == id) return Ok(dish);
    }
    return const Err(
      NotFoundFailure('Страву не знайдено', code: 'menu.dish_not_found'),
    );
  }

  @override
  Future<Result<BreakSlot?>> getNextBreak() async => const Ok(null);
}
