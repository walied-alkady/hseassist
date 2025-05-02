
import 'package:flutter/material.dart';

class QIconButton extends StatelessWidget {
  const QIconButton({
    super.key,
    required this.onPress,
    required this.icon,
  });

  final VoidCallback onPress;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          //gradient: cubit.gradient,
          border: Border.all(width: 2),
        ),
        child: Icon(icon),
      ),
    );
  }
}
