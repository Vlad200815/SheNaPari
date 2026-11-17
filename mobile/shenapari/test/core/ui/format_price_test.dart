import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/ui/format_price.dart';

void main() {
  test('whole hryvnias have no kopecks', () {
    expect(formatPrice(8500), '85 ₴');
    expect(formatPrice(0), '0 ₴');
  });

  test('kopecks always take two digits', () {
    expect(formatPrice(4250), '42,50 ₴');
    expect(formatPrice(1905), '19,05 ₴');
  });
}
