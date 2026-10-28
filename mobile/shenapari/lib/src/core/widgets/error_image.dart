import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shenapari/gen/colors.gen.dart';

import '../../../gen/assets.gen.dart';

class ErrorImage extends StatelessWidget {
  const ErrorImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //TODO: change test error icon
        SvgPicture.asset(Assets.images.icTestError.path, fit: BoxFit.cover),
        Center(
          child: SizedBox(
            height: 50,
            width: 50,
            child: SvgPicture.asset(
              //TODO: change test error icon
              Assets.images.icTestError.path,
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(
                ColorName.red,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
