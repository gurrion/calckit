import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final double? fontSize;
  final bool flex;

  const CalcButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
    this.textColor,
    this.fontSize,
    this.flex = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: color ?? theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              alignment: Alignment.center,
              height: 64,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? 22,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
