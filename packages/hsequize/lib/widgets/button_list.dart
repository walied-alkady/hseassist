
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hsequize/game_play_cubit.dart';
import 'package:hsequize/widgets/answer_button.dart';

class ButtonListView extends StatelessWidget {
  final List<String> options;
  final int correctIndex;
  const ButtonListView(
      {super.key, required this.options, required this.correctIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options
          .map((e) => AnswerButton(
                title: e,
                onTapAnswer: () => context.read<GameplayCubit>().onTapAnswer(context, e),
                correctAnswer: options[correctIndex],
              ))
          .toList(),
    );
  }
}
