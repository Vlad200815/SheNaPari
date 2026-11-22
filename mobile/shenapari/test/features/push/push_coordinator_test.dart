import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/device/push_messages.dart';
import 'package:shenapari/features/push/domain/push_repository.dart';
import 'package:shenapari/features/push/presentation/push_coordinator.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari_core/session/auth_tokens.dart';
import 'package:shenapari_core/session/session_repository_impl.dart';
import 'package:shenapari_core/storage/in_memory_token_storage.dart';

class _FakeMessages implements PushMessages {
  String? currentToken = 'token-1';
  PushTap? launchedFrom;
  final refresh = StreamController<String>.broadcast();
  final tapped = StreamController<PushTap>.broadcast();
  int inits = 0;
  int asks = 0;

  @override
  Future<void> init() async => inits++;

  @override
  Future<String?> token() async {
    asks++;
    return currentToken;
  }

  @override
  Stream<String> get tokenRefresh => refresh.stream;

  @override
  Stream<PushTap> get taps => tapped.stream;

  @override
  Future<PushTap?> initialTap() async => launchedFrom;
}

class _FakePushRepository implements PushRepository {
  final registered = <String>[];

  @override
  Future<Result<void>> register(String token) async {
    registered.add(token);
    return const Ok(null);
  }
}

void main() {
  late _FakeMessages messages;
  late _FakePushRepository repository;
  late SessionRepositoryImpl session;
  late List<String> opened;
  late PushCoordinator coordinator;

  const tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');

  setUp(() {
    messages = _FakeMessages();
    repository = _FakePushRepository();
    session = SessionRepositoryImpl(InMemoryTokenStorage());
    opened = [];
    coordinator = PushCoordinator(messages, repository, session);
  });

  tearDown(() => coordinator.dispose());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('signed out: no token is sent', () async {
    await coordinator.start(open: opened.add);

    expect(messages.inits, 1);
    expect(repository.registered, isEmpty);
  });

  test('signing in sends the device token', () async {
    await coordinator.start(open: opened.add);

    await session.save(tokens, isNewUser: false);
    await settle();

    expect(repository.registered, ['token-1']);
  });

  test('already signed in at start: sends it at once', () async {
    await session.save(tokens, isNewUser: false);

    await coordinator.start(open: opened.add);

    expect(repository.registered, ['token-1']);
  });

  test('a new token from Firebase is sent again', () async {
    await session.save(tokens, isNewUser: false);
    await coordinator.start(open: opened.add);

    messages.refresh.add('token-2');
    await settle();

    expect(repository.registered, ['token-1', 'token-2']);
  });

  test('no token (no Play services, iPhone): nothing to send', () async {
    messages.currentToken = null;
    await session.save(tokens, isNewUser: false);

    await coordinator.start(open: opened.add);

    expect(repository.registered, isEmpty);
  });

  test('a status push opens the order', () async {
    await session.save(tokens, isNewUser: false);
    await coordinator.start(open: opened.add);

    messages.tapped.add(const PushTap(type: 'order_status', orderId: 'o7'));
    await settle();

    expect(opened, ['/order/o7']);
  });

  test('«Як вам №36?» opens the order with the rating sheet', () async {
    await session.save(tokens, isNewUser: false);
    await coordinator.start(open: opened.add);

    messages.tapped.add(const PushTap(type: 'rate_order', orderId: 'o36'));
    await settle();

    expect(opened, ['/order/o36?rate=1']);
  });

  test('launched from a push before sign-in is known: opens once signed in', () async {
    messages.launchedFrom = const PushTap(type: 'order_status', orderId: 'o7');
    await coordinator.start(open: opened.add);
    expect(opened, isEmpty);

    await session.save(tokens, isNewUser: false);
    await settle();

    expect(opened, ['/order/o7']);
  });

  test('a push without an order opens nothing', () async {
    await session.save(tokens, isNewUser: false);
    await coordinator.start(open: opened.add);

    messages.tapped.add(const PushTap(type: 'news'));
    await settle();

    expect(opened, isEmpty);
  });

  test('push data is read from the FCM payload', () {
    expect(
      PushTap.fromData({'type': 'rate_order', 'orderId': 'o36'}),
      const PushTap(type: 'rate_order', orderId: 'o36'),
    );
    expect(PushTap.fromData({}), const PushTap(type: ''));
  });
}
