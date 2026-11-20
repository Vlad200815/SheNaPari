import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari_core/network/api_envelope.dart';

void main() {
  group('ApiEnvelope.fromJson', () {
    test('parses a successful response with data', () {
      final env = ApiEnvelope<String>.fromJson({
        'succeeded': true,
        'message': null,
        'data': 'pong',
        'errors': <String>[],
      }, (json) => json! as String);

      expect(env.succeeded, isTrue);
      expect(env.data, 'pong');
      expect(env.message, isNull);
      expect(env.errors, isEmpty);
      expect(env.code, isNull);
    });

    test('parses a successful response without data', () {
      final env = ApiEnvelope<String>.fromJson({
        'succeeded': true,
        'data': null,
        'errors': <String>[],
      }, (json) => json! as String);

      expect(env.succeeded, isTrue);
      expect(env.data, isNull);
    });

    test('parses an error response and does not touch data', () {
      final env = ApiEnvelope<String>.fromJson({
        'succeeded': false,
        'message': 'Замовлення ще не готове',
        'data': null,
        'errors': ['order.not_ready'],
      }, (json) => fail('data converter must not be called'));

      expect(env.succeeded, isFalse);
      expect(env.data, isNull);
      expect(env.message, 'Замовлення ще не готове');
      expect(env.errors, ['order.not_ready']);
      expect(env.code, 'order.not_ready');
    });

    test('tolerates missing message and errors', () {
      final env = ApiEnvelope<String>.fromJson({
        'succeeded': false,
      }, (json) => json! as String);

      expect(env.message, isNull);
      expect(env.errors, isEmpty);
      expect(env.code, isNull);
    });
  });

  group('ApiEnvelope.tryParse', () {
    test('returns null for a body that is not an envelope', () {
      expect(ApiEnvelope.tryParse('<html>502</html>'), isNull);
      expect(ApiEnvelope.tryParse(null), isNull);
      expect(ApiEnvelope.tryParse({'message': 'x'}), isNull);
    });

    test('returns the envelope for an error body', () {
      final env = ApiEnvelope.tryParse({
        'succeeded': false,
        'message': 'Не знайдено',
        'data': null,
        'errors': ['common.not_found'],
      });

      expect(env!.message, 'Не знайдено');
      expect(env.code, 'common.not_found');
    });
  });
}
