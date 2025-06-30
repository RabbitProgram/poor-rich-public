import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSpecial = false,
    this.icon,
    this.isLoading = false,
    this.customBackgroundColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isSpecial;
  final IconData? icon;
  final bool isLoading;
  final Color? customBackgroundColor;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    if (customBackgroundColor != null) {
      backgroundColor = customBackgroundColor!;
      textColor = Colors.white;
    } else if (isSpecial) {
      if (text == '⌫') {
        backgroundColor = Colors.orange[400]!;
        textColor = Colors.white;
      } else {
        backgroundColor = Colors.red[400]!;
        textColor = Colors.white;
      }
    } else {
      backgroundColor = Colors.grey[200]!;
      textColor = Colors.black87;
    }

    if (text.isEmpty && icon == null) {
      return const Expanded(child: SizedBox());
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        child: AspectRatio(
          aspectRatio: 1, // 正方形にする
          child: Material(
            color: backgroundColor,
            elevation: 1,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPressed,
              child: Center(
                child:
                    isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              textColor,
                            ),
                          ),
                        )
                        : icon != null
                        ? Icon(icon, size: 28, color: textColor)
                        : Text(
                          text,
                          style: TextStyle(
                            fontSize: text.length > 2 ? 24 : 28,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
