
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../game_play_cubit.dart';

class AnswerButton extends StatelessWidget {
  final VoidCallback onTapAnswer;
  final String title;
  final String correctAnswer;
  const AnswerButton({
    super.key,
    required this.onTapAnswer,
    required this.title,
    required this.correctAnswer,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapAnswer,
      child: BlocSelector<GameplayCubit, GameplayState, bool>(
        selector: (state) {
          return state.isAnswerPressed;
        },
        builder: (context, state) {
          Color buttonColor = Colors.white;
          if (state) {
            if (title == correctAnswer) {
              buttonColor = Colors.green.shade700;
            } else {
              buttonColor = Colors.red.shade700;
            }
          }

          return Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(23),
            ),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  const BoxShadow(color: Colors.black38),
                  BoxShadow(
                    color: buttonColor,
                    spreadRadius: -8.0,
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          );
        },
      ),
    );
  }
}
