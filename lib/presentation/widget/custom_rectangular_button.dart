import 'package:flutter/material.dart';
import 'package:zippy/presentation/theme/app_theme.dart';

class RectangularButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const RectangularButton({
    Key? key,
    this.color,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Wrap with Container to apply gradient ✨
      decoration: BoxDecoration(
        gradient: color != null
            ? null
            : Theme.of(context).extension<ThemeGradients>()?.darkBlueGradient,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          // Make button transparent to show gradient UwU
          backgroundColor: color ?? Colors.transparent,
          // Remove elevation and shadow
          elevation: 0,
          shadowColor: Colors.transparent,
          // Add splash effect
          foregroundColor: Colors.white.withOpacity(0.2),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
    );
  }
}
