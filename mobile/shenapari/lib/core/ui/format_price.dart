/// `8500` → `85 ₴`, `4250` → `42,50 ₴`.
String formatPrice(int kopecks) {
  final hryvnias = kopecks ~/ 100;
  final rest = kopecks % 100;
  if (rest == 0) return '$hryvnias ₴';
  return '$hryvnias,${rest.toString().padLeft(2, '0')} ₴';
}
