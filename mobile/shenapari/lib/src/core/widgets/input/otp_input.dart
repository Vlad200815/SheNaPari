// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
// import 'package:tms/gen/colors.gen.dart';
// import 'package:tms/src/app/config.dart';
// import 'package:tms/src/presentation/resource/theme_dimen.dart';
// import 'package:tms/src/presentation/resource/theme_text.dart';
//
// class OtpInput extends StatefulWidget {
//   final bool isError;
//   final int size;
//   final ValueChanged<String>? onChanged;
//   final TextEditingController controller;
//
//   const OtpInput({
//     super.key,
//     this.size = Config.OTP_CODE_SIZE,
//     this.isError = false,
//     this.onChanged,
//     required this.controller,
//   });
//
//   @override
//   _OtpInputState createState() => _OtpInputState();
//
//   @override
//   String toStringShort() => 'Rounded Filled';
// }
//
// class _OtpInputState extends State<OtpInput> {
//   final focusNode = FocusNode();
//
//   @override
//   void dispose() {
//     focusNode.dispose();
//     super.dispose();
//   }
//
//   bool showError = false;
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double itemWidth = (width / widget.size + 1);
//     double itemHeight = itemWidth * 0.85;
//
//     final defaultPinTheme = PinTheme(
//       margin: const EdgeInsets.all(4),
//       width: itemWidth,
//       height: itemHeight * 0.9,
//       textStyle: ThemeText.getBoldTextStyle(fontSize: 28),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(Dimen.CORNER_RADIUS),
//         color: ColorName.inputBackground
//       ),
//     );
//
//     return SizedBox(
//       height: itemHeight,
//       child: Pinput(
//         forceErrorState: widget.isError,
//         length: widget.size,
//         controller: widget.controller,
//         focusNode: focusNode,
//         defaultPinTheme: defaultPinTheme,
//         onCompleted: (pin) {},
//         onChanged: (pin) {
//           widget.onChanged?.call(pin);
//         },
//         focusedPinTheme: defaultPinTheme.copyWith(
//           height: itemHeight,
//           width: itemWidth,
//           decoration: defaultPinTheme.decoration!.copyWith(
//             border: Border.all(color: ColorName.menuSelected),
//           ),
//         ),
//         errorPinTheme: defaultPinTheme.copyWith(
//           decoration: defaultPinTheme.decoration!.copyWith(
//             border: Border.all(color: Colors.redAccent),
//           ),
//         ),
//       ),
//     );
//   }
// }
