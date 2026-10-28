// import 'package:flutter/material.dart';
// import 'package:tms/gen/colors.gen.dart';
//
// class AppCardWidget extends StatelessWidget {
//   const AppCardWidget({
//     super.key,
//     required this.content,
//     this.onTap,
//     this.padding,
//     this.radius = 16,
//     this.cutBorder = const BorderRadius.only(topRight: Radius.circular(16))
//   });
//
//   final Widget content;
//   final Function()? onTap;
//   final EdgeInsets? padding;
//   final double radius;
//   final BorderRadius cutBorder;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//         onTap: onTap,
//         splashColor: Colors.transparent,
//         child: Material(
//             color: Colors.transparent,
//             clipBehavior: Clip.antiAlias,
//             elevation: 8,
//             child: Container(
//                 width: double.maxFinite,
//                 padding: padding,
//                 decoration: BoxDecoration(
//                     color: ColorName.white,
//                     borderRadius: BorderRadius.circular(radius)
//                 ),
//                 child: content
//             )
//         )
//     );
//   }
// }
