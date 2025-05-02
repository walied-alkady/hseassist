
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hsequize/enums.dart';
import 'package:hsequize/game_play_cubit.dart';
import 'package:hsequize/widgets/base_scafold.dart';
import 'package:hsequize/widgets/button_list.dart';
import 'package:hsequize/widgets/count_down_timer.dart';
import 'package:hsequize/widgets/image_widget.dart';
import 'package:hsequize/widgets/score_bare.dart';

class QuizGameplayScreen extends StatelessWidget {
  static const routeName = '/QuizGameplayScreen';

  const QuizGameplayScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return BaseScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const ScoreBar(),
            const SizedBox(height: 10),
            CountDownTimer(whenTimeExpires: () => context.read<GameplayCubit>().levelEnd(context)),
            const SizedBox(height: 10),
            BlocBuilder<GameplayCubit, GameplayState>(
              builder: (BuildContext context, GameplayState state){
                return Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius:const BorderRadius.all(Radius.circular(30)),
                            border: Border.all(
                                color:Colors.white,
                                width: 8),
                          ),
                          child: getQuestion(context),
                        ),
                        const SizedBox(height: 20),
                        ButtonListView(
                          options: context.read<GameplayCubit>().state.selectedQuiz?.options ?? [],
                          correctIndex: context.read<GameplayCubit>().state.selectedQuiz?.correctIndex ?? 0,
                        ),
                        const SizedBox(height: 100),
                        Text( ' ${'question'.tr()}# ${context.read<GameplayCubit>().state.completedCount+1}'),
                      ],
                    ),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget getQuestion(BuildContext context) {

    if (context.read<GameplayCubit>().state.selectedQuiz?.questionType == QuizQuestionType.text) {
      final theme = Theme.of(context);
      return Text(
        context.read<GameplayCubit>().state.selectedQuiz?.question ?? '',
        style: theme.textTheme.titleMedium,
      );
    } else {
      return ImageWidget(
        imgPath: context.read<GameplayCubit>().state.selectedQuiz?.question ?? '',
        fit: BoxFit.contain,
      );
    }
  }
}
