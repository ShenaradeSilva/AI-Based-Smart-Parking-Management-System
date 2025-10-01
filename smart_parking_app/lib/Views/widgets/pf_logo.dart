import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PFLogo extends StatelessWidget {
  final double size;

  const PFLogo({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/pf_logo.svg', // exact path to SVG
      width: size,
      height: size,
    );
  }
}
