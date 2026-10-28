import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';

import 'update_info.dart';
import 'update_method.dart';

///
/// Client used to check if a force upgrade is needed
///
class BaseUpdateClient {
  const BaseUpdateClient({
    required this.fetchAppVersionInfo,
    required this.iosAppStoreId,
    required this.updateMethods,
    required this.otaPageBuilder,
  });

  static const _name = 'BaseUpdateClient';
  final Future<UpdateInfo> Function() fetchAppVersionInfo;
  final String iosAppStoreId;
  final List<UpdateMethod> updateMethods;
  final Widget Function(Stream<OtaEvent>) otaPageBuilder;

  ///
  /// Check has new app version
  ///
  Future<bool> hasAppUpdate() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      return false;
    }

    final info = await fetchAppVersionInfo();
    PlatformInfo? platformInfo = info.android;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformInfo = info.ios;
    }
    if ((platformInfo?.latestVersion).isNullOrEmpty()) {
      log('Latest version version not set. Ignoring.', name: _name);
      return false;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersionStr = RegExp(
      r'\d+\.\d+\.\d+',
    ).matchAsPrefix(packageInfo.version)!.group(0)!;

    final requiredVersionStr = (platformInfo?.minVersion).orEmpty();
    final latestVersionStr = (platformInfo?.latestVersion).orEmpty();

    final requiredVersion = Version.parse(requiredVersionStr);
    final currentVersion = Version.parse(currentVersionStr);

    final updateRequired = currentVersion < requiredVersion;
    log(
      'Update ${updateRequired ? '' : 'not '}required. '
      'Current version: $currentVersion, required version: $requiredVersion',
      name: _name,
    );
    return updateRequired;
  }

  ///
  /// Store URL for App Store / Play Store
  ///
  Future<String?> storeUrl() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosAppStoreId.isNotEmpty
          ? 'https://apps.apple.com/app/id$iosAppStoreId'
          : null;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final packageInfo = await PackageInfo.fromPlatform();
      return 'https://play.google.com/store/apps/details?id=${packageInfo.packageName}';
    }
    return null;
  }
}
