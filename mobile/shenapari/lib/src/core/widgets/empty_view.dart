// import 'package:flutter/material.dart';
// import 'package:shenapari/gen/colors.gen.dart';
// import 'package:shenapari/src/presentation/resource/theme_text.dart';
//
// class EmptyDataWidget extends StatelessWidget {
//   const EmptyDataWidget({
//     super.key,
//     required this.message,
//     this.buttonText,
//     this.onPressed,
//   });
//
//   final String message;
//   final String? buttonText;
//   final Function()? onPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.max,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           message,
//           style: ThemeText.getRegularTextStyle(
//             color: ColorName.primary400,
//             fontSize: 18,
//           ),
//         ),
//         if (onPressed != null)
//           Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: FilledButton(
//               onPressed: onPressed,
//               child: Text(buttonText ?? ""),
//             ),
//           ),
//       ],
//     );
//   }
// }
