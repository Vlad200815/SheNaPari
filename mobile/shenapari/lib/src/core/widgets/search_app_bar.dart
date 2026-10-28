// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:shenapari/generated/locale_keys.g.dart';
// import 'package:shenapari/src/presentation/widgets/image_view.dart';
//
// import '../../../gen/assets.gen.dart';
// import '../../../gen/colors.gen.dart';
// import '../resource/theme_dimen.dart';
// import '../resource/theme_text.dart';
//
// class SearchAppBar extends StatefulWidget {
//   const SearchAppBar({
//     super.key,
//     this.onChanged,
//     this.readOnly = true,
//     this.isWithSuffix = false,
//
//     this.onTap,
//     required this.isWithFilterBtn,
//     this.filterOnPressed,
//     this.focusNode,
//   });
//
//   final bool isWithFilterBtn;
//   final void Function(String)? onChanged;
//   final bool readOnly;
//   final void Function()? onTap;
//   final FocusNode? focusNode;
//   final bool isWithSuffix;
//   final void Function()? filterOnPressed;
//
//   @override
//   State<SearchAppBar> createState() => _SearchAppBarState();
// }
//
// class _SearchAppBarState extends State<SearchAppBar> {
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return SliverPadding(
//       padding: EdgeInsets.only(top: 16, bottom: 10),
//       sliver: SliverAppBar(
//         elevation: 0,
//         pinned: true,
//         floating: true,
//         surfaceTintColor: Colors.transparent,
//         backgroundColor: ColorName.white,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: TextField(
//                 keyboardType: TextInputType.name,
//                 controller: _searchController,
//                 focusNode: widget.focusNode,
//                 onTap: widget.onTap,
//                 readOnly: widget.readOnly,
//                 onChanged: widget.onChanged,
//                 style: ThemeText.getRegularTextStyle(
//                   color: ColorName.secondary50,
//                 ),
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(Dimen.CORNER_RADIUS),
//                     borderSide: BorderSide(color: ColorName.secondary25),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: ColorName.secondary25,
//                       width: Dimen.DEFAULT_BORDER_WIDTH,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: ColorName.secondary),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: ColorName.red),
//                   ),
//
//                   alignLabelWithHint: true,
//                   prefixIcon: Transform.scale(
//                     scale: 0.5,
//                     child: Assets.images.icSearch.svg(),
//                   ),
//                   suffixIcon:
//                       widget.isWithSuffix && _searchController.text.isNotEmpty
//                       ? SizedBox(
//                           height: 24,
//                           width: 24,
//                           child: IconButton(
//                             onPressed: () => setState(() {
//                               _searchController.clear();
//                             }),
//                             icon: ImageView(
//                               imageUrl: Assets.images.icCancel.path,
//                               iconColor: ColorName.primary,
//                             ),
//                           ),
//                         )
//                       : null,
//
//                   hintText: LocaleKeys.app_search_bar_hint.tr(),
//                   hintStyle: ThemeText.getRegularTextStyle(
//                     color: ColorName.secondary50,
//                   ),
//                 ),
//               ),
//             ),
//
//             widget.isWithFilterBtn
//                 ? IconButton(
//                     onPressed: widget.filterOnPressed,
//                     icon: ImageView(
//                       imageUrl: Assets.images.icFilterList.path,
//                       iconColor: ColorName.secondary,
//                     ),
//                   )
//                 : SizedBox(),
//           ],
//         ),
//       ),
//     );
//   }
// }
