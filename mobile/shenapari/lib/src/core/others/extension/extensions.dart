import 'dart:core';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

extension ListExtension<T> on List<T>? {
  List<T> orEmpty() {
    return this ?? [];
  }

  bool isNullOrEmpty() {
    return (this ?? []).isEmpty;
  }

  T? firstOrNull() {
    return (isNullOrEmpty()) ? null : this?.first;
  }

  T? random() {
    return (isNullOrEmpty()) ? null : (this?..shuffle()).firstOrNull();
  }
}

extension MapExtension<K, T> on Map<K, T>? {
  Map<K, T> orEmpty() {
    return this ?? {};
  }

  bool isNullOrEmpty() {
    return (this ?? {}).isEmpty;
  }

  bool isEmpty() {
    return this != null && this!.isEmpty;
  }
}

// extension ColorExtension on String {
//   ui.Color toColor() {
//     var hexColor = replaceAll("#", "");
//     if (hexColor.length == 6) {
//       hexColor = "FF$hexColor";
//     }
//     if (hexColor.length == 8) {
//       return Color(int.parse("0x$hexColor"));
//     }
//   }
// }

extension TextStyleX on TextStyle {
  /// A method to underline a text with a customizable [distance] between the text
  /// and underline. The [color], [thickness] and [style] can be set
  /// as the decorations of a [TextStyle].
  TextStyle underlined({
    Color? color,
    double distance = 1,
    double thickness = 1,
    TextDecorationStyle style = TextDecorationStyle.solid,
  }) {
    return copyWith(
      shadows: [
        Shadow(color: this.color ?? Colors.black, offset: Offset(0, -distance)),
      ],
      color: Colors.transparent,
      decoration: TextDecoration.underline,
      decorationThickness: thickness,
      decorationColor: color ?? this.color,
      decorationStyle: style,
    );
  }
}

extension StringExtensions on String? {
  bool isNullOrEmpty() {
    return (this ?? "").isEmpty;
  }

  String orEmpty() {
    return this ?? "";
  }

  String orValue(String value) {
    return this ?? value;
  }

  int toNumber() {
    return int.tryParse(orEmpty().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  DateTime toDateTime() {
    return DateTime.tryParse(orEmpty()) ?? DateTime.now();
  }

  String? toDateFormatted({
    String format = "kk:mm, dd MMMM yyyy",
    String locale = 'uk',
  }) {
    final dateTime = DateTime.tryParse(orEmpty());
    return intl.DateFormat(format, locale).format(dateTime ?? DateTime.now());
  }
}

extension DoubleExtensions on double? {
  double orZero() {
    return this ?? 0.0;
  }

  double toPrecision(int n) => double.parse(orZero().toStringAsFixed(n));

  String toEuro() {
    return intl.NumberFormat.simpleCurrency(name: 'EUR').format(orZero());
  }
}

extension IntExtensions on int? {
  int orZero() {
    return this ?? 0;
  }

  int orValue(int value) {
    return this ?? value;
  }

  String formatNumber() {
    if (orZero() < 10000) {
      return toString();
    } else {
      double thousands = orZero() / 1000;
      return '${thousands.toStringAsFixed(0)}k';
    }
  }
}

extension NumExtensions on num? {
  num orZero() {
    return this ?? 0;
  }

  num orValue(num value) {
    return this ?? value;
  }
}

extension BoolExtensions on bool? {
  bool orFalse() {
    return this ?? false;
  }

  bool orTrue() {
    return this ?? true;
  }

  bool isTrue() {
    return this == true;
  }

  bool isFalse() {
    return this == false;
  }

  bool orValue(bool value) {
    return this ?? value;
  }
}

extension DateTimeExtensions on DateTime {
  String format({String pattern = 'dd MMMM yyyy kk:mm'}) {
    DateTime now = this ?? DateTime.now();
    return intl.DateFormat(pattern).format(now);
  }

  String toHumanReadable({String locale = 'uk'}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(year, month, day);

    final timeString = intl.DateFormat('HH:mm', locale).format(this);

    if (date == today) {
      return 'Сьогодні, $timeString';
    } else if (date == yesterday) {
      return 'Вчора, $timeString';
    } else if (year == now.year) {
      return intl.DateFormat(
        'd MMMM HH:mm',
        locale,
      ).format(this); // приклад: "11 серп."
    } else {
      return intl.DateFormat(
        'd MMMM yyyy, HH:mm',
        locale,
      ).format(this); // приклад: "10 лют. 2024"
    }
  }
}

extension GlobalKeyExtensions on GlobalKey {
  Size? getSize() {
    return (currentContext?.findRenderObject() as RenderBox?)?.size;
  }
}

extension GoRouteExtensions on GoRoute {
  GoRoute toStackRoute() {
    return GoRoute(
      path: path.replaceFirst("/", ""),
      name: name,
      builder: builder,
      pageBuilder: pageBuilder,
      parentNavigatorKey: parentNavigatorKey,
      redirect: redirect,
      onExit: onExit,
      routes: routes,
    );
  }
}

// extension GoRouterExtension on GoRouter {
//   void clearStackAndNavigate(String name,
//       {Map<String, String> pathParameters = const <String, String>{},
//         Map<String, dynamic> queryParameters = const <String, dynamic>{},
//         Object? extra}) {
//     while (canPop()) {
//       if (name != HomePage.route().name) {
//         pop();
//       }
//     }
//     pushReplacementNamed(name,
//         pathParameters: pathParameters,
//         queryParameters: queryParameters,
//         extra: extra);
//   }
// }

// extension ToBitDescription on Widget {
//   Future<BitmapDescriptor> toBitmapDescriptor(
//       {Size? logicalSize,
//         Size? imageSize,
//         Duration waitToRender = const Duration(milliseconds: 300),
//         TextDirection textDirection = TextDirection.ltr}) async {
//     final widget = RepaintBoundary(
//       child: MediaQuery(
//           data: const MediaQueryData(),
//           child: Directionality(textDirection: TextDirection.ltr, child: this)),
//     );
//     final pngBytes = await createImageFromWidget(widget,
//         waitToRender: waitToRender,
//         logicalSize: logicalSize,
//         imageSize: imageSize);
//     return BitmapDescriptor.fromBytes(pngBytes);
//   }
// }

/// Creates an image from the given widget by first spinning up a element and render tree,
/// wait [waitToRender] to render the widget that take time like network and asset images

/// The final image will be of size [imageSize] and the the widget will be layout, ... with the given [logicalSize].
/// By default Value of  [imageSize] and [logicalSize] will be calculate from the app main window

Future<Uint8List> createImageFromWidget(
  Widget widget, {
  Size? logicalSize,
  required Duration waitToRender,
  Size? imageSize,
}) async {
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
  final view = ui.PlatformDispatcher.instance.views.first;
  logicalSize ??= view.physicalSize / view.devicePixelRatio;
  imageSize ??= view.physicalSize;

  // assert(logicalSize.aspectRatio == imageSize.aspectRatio);

  final RenderView renderView = RenderView(
    view: view,
    child: RenderPositionedBox(
      alignment: Alignment.center,
      child: repaintBoundary,
    ),
    configuration: const ViewConfiguration(devicePixelRatio: 1.0),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final RenderObjectToWidgetElement<RenderBox> rootElement =
      RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: widget,
      ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);

  await Future.delayed(waitToRender);

  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final ui.Image image = await repaintBoundary.toImage(
    pixelRatio: imageSize.width / logicalSize.width,
  );
  final ByteData? byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  return byteData!.buffer.asUint8List();
}

// extension UrlExtensions on String {
//   Future<void> openLink() async {
//     final uri = Uri.parse(this);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }
// }

extension DurationExtension on Duration {
  String formatDuration() {
    if (isNegative || this == Duration.zero) {
      return '00:00';
    }
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(inMinutes.remainder(60));
    final seconds = twoDigits(inSeconds.remainder(60));
    print('Formatting duration: $this -> $minutes:$seconds');
    return '$minutes:$seconds';
  }
}

// extension PagingControllerUpdateExt<PageKeyType, ItemType> on PagingController<PageKeyType, ItemType> {
//
//   void updateItem(bool Function(ItemType item) matcher, ItemType updatedItem) {
//     final pages = value.pages;
//
//     if (pages == null) return;
//
//     for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
//       final page = pages[pageIndex];
//       final itemIndex = page.indexWhere(matcher);
//
//       if (itemIndex != -1) {
//         final newPage = List<ItemType>.from(page);
//         newPage[itemIndex] = updatedItem;
//
//         final newPages = List<List<ItemType>>.from(pages);
//         newPages[pageIndex] = newPage;
//
//         value = value.copyWith(pages: newPages);
//         break;
//       }
//     }
//   }
// }

extension HexColorExtension on String? {
  Color toColor({Color fallback = Colors.black}) {
    if (this == null) return fallback;

    final raw = this!.trim();

    if (raw.isEmpty) return fallback;

    final hex = raw.startsWith('#') ? raw.substring(1) : raw;

    if (hex.length != 6 && hex.length != 8) return fallback;

    final buffer = StringBuffer();

    if (hex.length == 6) buffer.write('ff');

    buffer.write(hex);

    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}

extension ColorHexExtension on Color {
  /// Повертає колір у форматі "#RRGGBB" (ігнорує альфа)
  String toHex({bool leadingHashSign = true}) {
    final hex = toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    // hex: AARRGGBB
    final rgb = hex.substring(2); // беремо RRGGBB
    return leadingHashSign ? '#$rgb' : rgb;
  }

  /// Повертає колір у форматі "#AARRGGBB" (включно з альфа)
  String toHexWithAlpha({bool leadingHashSign = true}) {
    final hex = toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    return leadingHashSign ? '#$hex' : hex;
  }

  /// Повертає колір у форматі "RRGGBB" без #
  String toHexNoHash() => toHex(leadingHashSign: false);

  /// Повертає колір у форматі "AARRGGBB" без #
  String toHexWithAlphaNoHash() => toHexWithAlpha(leadingHashSign: false);
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
