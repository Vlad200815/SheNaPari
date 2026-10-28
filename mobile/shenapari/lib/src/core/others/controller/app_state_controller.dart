// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shenapari/src/core/fcm_service.dart';
// import 'package:shenapari/src/presentation/others/extention/extensions.dart';
//
// import '../../data/storage/local/preference/app_preference.dart' as pref;
//
// ///
// /// Global application state manager
// ///
// class AppStateController extends GetxController {
//   static const TAG = "AppStateController:: ";
//
//   // final SubscribeToNotificationsUseCase _subscribeToNotificationsUseCase = di
//   //     .get();
//
//   Rx<bool> isAuthorized = false.obs;
//   Rx<bool> isShowedIntro = false.obs;
//
//   final Rx<Key> appKey = UniqueKey().obs;
//
//   @override
//   void onReady() async {
//     super.onReady();
//     print("$TAG onReady");
//     await _fetchAuth();
//     // await _fetchFCMToken();
//   }
//
//   void restartApp() {
//     appKey.value = UniqueKey();
//   }
//
//   ///
//   /// Fetch actual FCM token
//   ///
//
//   Future<void> _fetchFCMToken() async {
//     String token = await pref.AppPreference.fcmToken;
//     final hasToken = !token.isNullOrEmpty();
//     if (!hasToken) {
//       try {
//         final value = await FCMService().getFCMToken();
//
//         pref.AppPreference.setFcmToken(value.orEmpty());
//         await _subscribeToPushNotifications();
//         print("$TAG FCM token $value");
//       } on Exception catch (error) {
//         print("$TAG Error fetch FCM token: $error");
//       }
//     } else {
//       print("$TAG FCM token $token");
//       await _subscribeToPushNotifications();
//     }
//   }
//
//   ///
//   /// Fetch auth status
//   ///
//   Future<void> _fetchAuth() async {
//     final value = (await pref.AppPreference.isAuthenticated);
//     isAuthorized.value = value;
//     print("$TAG Fetch auth status: $value");
//   }
//
//   ///
//   /// Subscribe to push notifications
//   ///
//
//   Future<void> _subscribeToPushNotifications() async {
//     try {
//       // await _subscribeToNotificationsUseCase.perform();
//       print("$TAG Subscribed to notifications.");
//     } on Exception catch (error) {
//       print("$TAG Error subscribe to notification: $error");
//     }
//   }
// }
