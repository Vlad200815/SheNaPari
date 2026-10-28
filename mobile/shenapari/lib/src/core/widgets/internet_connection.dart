// import 'package:easy_localization/easy_localization.dart' as td;
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tms/gen/colors.gen.dart';
// import 'package:tms/generated/locale_keys.g.dart';
// import 'package:tms/src/domain/controller/connectivity_controller.dart';
// import 'package:tms/src/presentation/resource/theme_text.dart';
//
// class InternetConnectionWidget extends StatefulWidget
//     implements PreferredSizeWidget {
//   const InternetConnectionWidget({super.key, this.connectionListener});
//
//   final Function(bool)? connectionListener;
//
//   @override
//   State<InternetConnectionWidget> createState() =>
//       _InternetConnectionWidgetState();
//
//   @override
//   Size get preferredSize => const Size.fromHeight(24);
// }
//
// class _InternetConnectionWidgetState extends State<InternetConnectionWidget> {
//   final ConnectivityController _connectivityController = Get.find();
//   var isInternetConnection = true;
//   var isVisible = false;
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   initState() {
//     super.initState();
//     _onConnectionChanged(_connectivityController.hasConnection.value);
//     _connectivityController.hasConnection.listen((isConnected) {
//       _onConnectionChanged(isConnected);
//     });
//   }
//
//   void _onConnectionChanged(bool isConnected) {
//     // print("_internetSignal LISTEN $isConnected");
//     if (mounted) {
//       widget.connectionListener?.call(isConnected);
//       setState(() {
//         isInternetConnection = isConnected;
//         if (isInternetConnection) {
//           if (mounted) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               Future.delayed(const Duration(seconds: 3), () {
//                 if (mounted) {
//                   setState(() {
//                     if (isInternetConnection) {
//                       isVisible = false;
//                     }
//                   });
//                 }
//               });
//             });
//           }
//         } else {
//           setState(() {
//             isVisible = true;
//           });
//         }
//       });
//     }
//   }
//
//   @override
//   Widget build(context) {
//     return AnimatedContainer(
//       height: isVisible ? 24.0 : 0.0,
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       color: (isInternetConnection == false)
//           ? ColorName.notificationBadgeImportantBg
//           : ColorName.statusApprovedBackground,
//       duration: const Duration(milliseconds: 350),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             (isInternetConnection == false)
//                 ? td.tr(LocaleKeys.app_internet_connection_off)
//                 : td.tr(LocaleKeys.app_internet_connection_on),
//             style: ThemeText.getMediumTextStyle(
//               fontSize: 16,
//               color: (isInternetConnection == false)
//                   ? ColorName.statusRejectedText
//                   : ColorName.statusApprovedText,
//               letterSpacing: 0,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
