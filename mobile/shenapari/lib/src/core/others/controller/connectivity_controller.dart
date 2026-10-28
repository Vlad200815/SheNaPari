import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:data_strength/data_strength.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';


/// TODO: I commented everything where data_strength package was used
/// TODO: Redo this connectivity controller

class ConnectivityController extends GetxController {

  static ConnectivityController getInstance() => ConnectivityController._();

  ConnectivityController._() {
      _initTracking();
  }

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;

  late Timer _timer;
  // final _internetSignal = DataStrength();
  int? _mobileSignal;
  int? _wifiSignal;
  String? _networkType;

  final _connectionType = ConnectivityResult.none.obs;
  ConnectivityResult get connectionType => _connectionType.value;
  set connectionType(value) {
    _connectionType.value = value;
  }

  final _hasConnection = true.obs;
  RxBool get hasConnection => _hasConnection;

  Future<void> _initTracking() async {
    await requestPhonePermission();
    getConnectivityType();
    _streamSubscription = _connectivity.onConnectivityChanged.listen(_listener);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      getConnectivityType();
    });
  }

  Future<void> getConnectivityType() async {
    late List<ConnectivityResult> connectivityResult;
    try {
      connectivityResult = await (_connectivity.checkConnectivity());
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return _listener(connectivityResult);
  }

  // Future<void> _fetchInternetSignal() async {
  //   try {
  //     if (Platform.isAndroid) {
  //       _mobileSignal = await _internetSignal.getMobileSignalStrength();
  //       _wifiSignal = await _internetSignal.getWifiSignalStrength();
  //     }
  //     final hasPermission = await hasPhonePermission();
  //     if (Platform.isIOS || hasPermission) {
  //       _networkType = await _internetSignal.getNetworkType();
  //     }
  //     print("_internetSignal FETCH $_mobileSignal ${DataStrength.mobRangeName(_mobileSignal)}, $_wifiSignal ${DataStrength.rangeName(_wifiSignal)}, $_networkType");
  //   } on Exception catch(error) {
  //     if (kDebugMode) print('Error get internet signal.');
  //   }
  // }

  Future<void> _listener(List<ConnectivityResult> result) async {
    print("_internetSignal _listener");
    connectionType = result.first;
    // await _fetchInternetSignal();

    switch (connectionType) {
      case ConnectivityResult.mobile || ConnectivityResult.wifi || ConnectivityResult.vpn: {
          // _hasConnection.value = isNetworkConnectionStrength();
      }
      case ConnectivityResult.bluetooth || ConnectivityResult.ethernet || ConnectivityResult.other: {}
      default: {
          _hasConnection.value = false;
        }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
    _timer.cancel();
  }

  // bool isNetworkConnectionStrength() {
  //   if (kDebugMode) {
  //     print("_internetSignal ${isStrengthNetworkType()} ${isMobileSignalStrength()} ${isWifiSignalStrength()}");
  //   }
  //   return isStrengthNetworkType() && (isMobileSignalStrength() || isWifiSignalStrength());
  // }

  // bool isMobileSignalStrength() {
  //   /// Can't detect signal strength on iOS
  //   if (Platform.isIOS) return true;
  //   if (_mobileSignal == null) return false;
  //   try {
  //     final mobileRange = DataStrength.mobileRange(_mobileSignal);
  //     return (mobileRange != null && mobileRange! >= 0 && mobileRange! <= 3);
  //   } on Exception catch (_) {
  //     return false;
  //   }
  // }

  // bool isWifiSignalStrength() {
  //   /// Can't detect signal strength on iOS
  //   if (Platform.isIOS) return true;
  //   if (_wifiSignal == null) return false;
  //   try {
  //     final rangeValue = DataStrength.range(_wifiSignal);
  //     return rangeValue != null && rangeValue! >= 0 && rangeValue! <= 1;
  //   } on Exception catch (_) {
  //     return false;
  //   }
  // }

  bool isStrengthNetworkType() {
    final networkType = getNetworkType();
    if (kDebugMode) {
      print("_internetSignal NetworkType $networkType");
    }
    return networkType == NetworkType.mobile3G ||
        networkType == NetworkType.mobile4G ||
        networkType == NetworkType.mobile5G ||
        networkType == NetworkType.wifi;
  }

  NetworkType getNetworkType() {
    return NetworkHelper.getNetworkType(_networkType);
  }

  Future<bool> hasPhonePermission() async {
    var status = await Permission.phone.status;
    return status.isGranted;
  }

  Future<void> requestPhonePermission() async {
    var status = await Permission.phone.status;

    if (status.isDenied) {
      PermissionStatus result = await Permission.phone.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}

enum NetworkType {
  mobile2G,
  mobile3G,
  mobile4G,
  mobile5G,
  wifi,
  unknown,
}

class NetworkHelper {
  static NetworkType getNetworkType(String? network) {
    switch (network?.toLowerCase()) {
      case '2g':
        return NetworkType.mobile2G;
      case '3g':
        return NetworkType.mobile3G;
      case '4g':
        return NetworkType.mobile4G;
      case '5g':
        return NetworkType.mobile5G;
      case 'wi-fi':
        return NetworkType.wifi;
      default:
        return NetworkType.unknown;
    }
  }
}