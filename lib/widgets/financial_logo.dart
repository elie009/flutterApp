import 'package:flutter/material.dart';

class FinancialLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const FinancialLogo({
    super.key,
    this.size = 80,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Image.asset(
      '/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox.square(
        dimension: size,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      ),
    );

   
    return logo;
  }
}
