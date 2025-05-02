
import 'package:flutter/material.dart';

class ScoreContainer extends StatelessWidget {
  final String leadingImg;
  final String score;
  final VoidCallback onPress;

  const ScoreContainer({
    super.key,
    required this.leadingImg,
    required this.score,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPress,
      child: Container(
        height: 25,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: const [0, 1],
            begin: const Alignment(1, 1),
            end: const Alignment(1, -1),
            colors: [theme.secondaryHeaderColor, theme.primaryColorDark],
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: Colors.orange),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image(image: AssetImage(leadingImg)),
            Text(score),
            Container(
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
