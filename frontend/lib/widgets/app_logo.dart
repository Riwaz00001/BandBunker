
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;

  const AppLogo({
    super.key,
    this.width = 120,
  });

  @override
  Widget build(BuildContext context) {

    // Check the current theme
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    // Select the appropriate logo
    final logoPath = isDarkMode
        ? 'assets/logos/logo_dark_transparent.png'
        : 'assets/logos/logo_light_transparent.png';

    return Image.asset(
      logoPath,
      width: width,
      fit: BoxFit.contain,
    );
  }
}
