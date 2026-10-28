import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

import 'base_update_client.dart';
import 'update_info.dart';
import 'update_method.dart';

const DELAY_CHECK_NEW_VERSION = 1;

class BaseUpdateWidget extends StatefulWidget {
  const BaseUpdateWidget({
    super.key,
    required this.child,
    required this.navigatorKey,
    required this.updateClient,
    required this.showUpdateAlert,
    this.onException,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final BaseUpdateClient updateClient;
  final Future<bool?> Function(BuildContext context, bool allowCancel)
  showUpdateAlert;
  final void Function(Object error, StackTrace? stackTrace)? onException;

  @override
  State<BaseUpdateWidget> createState() => _BaseUpdateWidgetState();
}

class _BaseUpdateWidgetState extends State<BaseUpdateWidget>
    with WidgetsBindingObserver {
  var _isAlertVisible = false;
  var _isUpdateInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkIfAppUpdateIsNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isUpdateInProgress) {
      _checkIfAppUpdateIsNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  DateTime? _lastChecked;
  Future<bool> _isUpdateRequired(UpdateInfo updateInfo) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      return false;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersionStr =
        RegExp(r'\d+\.\d+\.\d+').matchAsPrefix(packageInfo.version)?.group(0) ??
        packageInfo.version;

    final platformInfo = defaultTargetPlatform == TargetPlatform.android
        ? updateInfo.android
        : updateInfo.ios;
    if (platformInfo == null || platformInfo.latestVersion.isEmpty) {
      debugPrint('No platform info or latest version available');
      return false;
    }

    try {
      final currentVersion = Version.parse(currentVersionStr);
      final minVersion = Version.parse(
        platformInfo.minVersion.isEmpty ? '0.0.0' : platformInfo.minVersion,
      );
      final latestVersion = Version.parse(platformInfo.latestVersion);

      debugPrint(
        'Current: $currentVersion, Min: $minVersion, Latest: $latestVersion',
      );
      return currentVersion <
          latestVersion; // Оновлення потрібне, якщо поточна версія < latestVersion
    } catch (e) {
      debugPrint('Error parsing versions: $e');
      return false;
    }
  }

  Future<bool> _isForceUpdate(UpdateInfo updateInfo) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersionStr =
        RegExp(r'\d+\.\d+\.\d+').matchAsPrefix(packageInfo.version)?.group(0) ??
        packageInfo.version;

    final platformInfo = defaultTargetPlatform == TargetPlatform.android
        ? updateInfo.android
        : updateInfo.ios;
    if (platformInfo == null || platformInfo.minVersion.isEmpty) {
      return false;
    }

    try {
      final currentVersion = Version.parse(currentVersionStr);
      final minVersion = Version.parse(platformInfo.minVersion);
      return currentVersion <
          minVersion; // Примусове, якщо поточна версія < minVersion
    } catch (e) {
      debugPrint('Error parsing versions for force update: $e');
      return false;
    }
  }

  Future<void> _checkIfAppUpdateIsNeeded() async {
    if (_isAlertVisible || _isUpdateInProgress) return;
    if (_lastChecked != null &&
        DateTime.now().difference(_lastChecked!).inMinutes <
            DELAY_CHECK_NEW_VERSION) {
      return;
    }
    _lastChecked = DateTime.now();

    try {
      final updateInfo = await widget.updateClient.fetchAppVersionInfo();
      final hasUpdate = await _isUpdateRequired(updateInfo);
      if (hasUpdate) {
        _isUpdateInProgress = true;
        final isForceUpdate = await _isForceUpdate(updateInfo);
        await _triggerUpdate(updateInfo, !isForceUpdate);
        _isUpdateInProgress = false;
      }
    } catch (e, st) {
      _isUpdateInProgress = false;
      final handler = widget.onException;
      if (handler != null) {
        handler(e, st);
      } else {
        debugPrint('Update check failed: $e');
        rethrow;
      }
    }
  }

  Future<void> _triggerUpdate(UpdateInfo updateInfo, bool allowCancel) async {
    final ctx = widget.navigatorKey.currentContext ?? context;
    if (_isAlertVisible) return;
    _isAlertVisible = true;

    try {
      final success = await widget.showUpdateAlert(ctx, allowCancel);
      _isAlertVisible = false;

      if (success == true) {
        final methods = widget.updateClient.updateMethods;
        final platformInfo = defaultTargetPlatform == TargetPlatform.android
            ? updateInfo.android
            : updateInfo.ios;

        for (final method in methods) {
          if (defaultTargetPlatform == TargetPlatform.iOS &&
              method != UpdateMethod.store) {
            continue;
          }

          try {
            if (method == UpdateMethod.ota &&
                defaultTargetPlatform == TargetPlatform.android &&
                platformInfo?.apkUrl != null) {
              debugPrint(
                'Starting OTA update with URL: ${platformInfo!.apkUrl}',
              );
              final otaStream = OtaUpdate().execute(
                platformInfo.apkUrl!,
                destinationFilename: 'app_update.apk',
              );
              await Navigator.of(ctx).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => widget.updateClient.otaPageBuilder(otaStream),
                ),
              );
              return;
            } else if (method == UpdateMethod.native &&
                defaultTargetPlatform == TargetPlatform.android) {
              try {
                final updateInfo1 = await InAppUpdate.checkForUpdate();
                if (updateInfo1.updateAvailability ==
                    UpdateAvailability.updateAvailable) {
                  if (await _isForceUpdate(updateInfo)) {
                    await InAppUpdate.performImmediateUpdate();
                  } else {
                    await InAppUpdate.startFlexibleUpdate();
                  }
                  return;
                }
              } catch (e) {
                debugPrint('Native in-app update failed: $e');
              }
            } else if (method == UpdateMethod.store) {
              final storeUrl = await widget.updateClient.storeUrl();
              if (storeUrl != null) {
                await launchUrl(
                  Uri.parse(storeUrl),
                  mode: LaunchMode.externalApplication,
                );
                return;
              }
            }
          } catch (e, st) {
            debugPrint('Error with update method $method: $e');
            final handler = widget.onException;
            if (handler != null) {
              handler(e, st);
            }
          }
        }
      } else if (success == null && !allowCancel) {
        await _triggerUpdate(updateInfo, allowCancel);
      }
    } catch (e, st) {
      _isAlertVisible = false;
      final handler = widget.onException;
      if (handler != null) {
        handler(e, st);
      } else {
        debugPrint('Update trigger failed: $e');
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
