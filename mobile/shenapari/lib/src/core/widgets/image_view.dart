import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../gen/colors.gen.dart';
import 'error_image.dart';

enum _ImageType {
  networkSvg,
  network,
  deviceSvg,
  device,
  assetSvg,
  asset;

  static _ImageType resolve(String url) {
    final bool isSvg = url.endsWith('.svg');

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return isSvg ? networkSvg : network;
    }
    if (url.startsWith('/data') || url.startsWith('/var')) {
      return isSvg ? deviceSvg : device;
    }
    return isSvg ? assetSvg : asset;
  }
}

class ImageView extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Alignment alignment;
  final Color? iconColor;

  const ImageView({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.iconColor,
  });

  ColorFilter? get _colorFilter =>
      iconColor != null ? ColorFilter.mode(iconColor!, BlendMode.srcIn) : null;

  Widget _placeholder({double? resolvedWidth, double? resolvedHeight}) =>
      Container(
        width: resolvedWidth ?? width,
        height: resolvedHeight ?? height,
        color: ColorName.secondary50,
      );

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return ErrorImage();

    return switch (_ImageType.resolve(url)) {
      /// SVG Network
      _ImageType.networkSvg => SvgPicture.network(
        url,
        height: height,
        width: width,
        placeholderBuilder: (_) => _placeholder(),
        errorBuilder: (_, _, _) => ErrorImage(),
      ),

      /// Network
      _ImageType.network => LayoutBuilder(
        builder: (context, constraints) {
          final dpr = MediaQuery.devicePixelRatioOf(context);
          final resolvedWidth = width ?? constraints.maxWidth;
          final resolvedHeight =
              height ??
              (constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : resolvedWidth);
          final cacheW = (resolvedWidth * dpr).toInt();
          final cacheH = (resolvedHeight * dpr).toInt();

          return CachedNetworkImage(
            imageUrl: url,
            width: resolvedWidth,
            height: resolvedHeight,
            fit: fit,
            alignment: alignment,
            memCacheWidth: cacheW,
            memCacheHeight: cacheH,
            maxWidthDiskCache: cacheW * 2,
            maxHeightDiskCache: cacheH * 2,
            placeholder: (context, url) => _placeholder(
              resolvedWidth: resolvedWidth,
              resolvedHeight: resolvedHeight,
            ),
            fadeInDuration: const Duration(milliseconds: 400),
            errorWidget: (context, error, stackTrace) => ErrorImage(),
          );
        },
      ),

      /// SVG Device
      _ImageType.deviceSvg => SvgPicture.file(
        File(url),
        height: height,
        width: width,
      ),

      /// Device
      _ImageType.device => Image.file(
        File(url),
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => ErrorImage(),
      ),

      /// SVG Asset
      _ImageType.assetSvg => SvgPicture.asset(
        url,
        height: height,
        width: width,
        fit: fit,
        colorFilter: _colorFilter,
        placeholderBuilder: (context) => _placeholder(),
        errorBuilder: (context, error, stackTrace) => ErrorImage(),
      ),

      /// Asset
      _ImageType.asset => Image.asset(
        url,
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => ErrorImage(),
        frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: child,
          );
        },
      ),
    };
  }
}
