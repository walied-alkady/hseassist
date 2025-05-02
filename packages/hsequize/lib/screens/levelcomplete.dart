
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hsequize/game_play_cubit.dart';
import 'package:hsequize/widgets/base_scafold.dart';
import 'package:hsequize/widgets/label_header.dart';

class LevelCompleteScreen extends StatelessWidget {
  static const routeName = '/LevelCompleteScreen';
  const LevelCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Future.delayed(
    //     const Duration(seconds: 1),
    //     () => cubit
    //         .onTapEvent
    //         ?.call(context, QuizEventAction.levelComplete));

    final theme = Theme.of(context);
    return BaseScaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LabelHeader(title: 'congratulations'.tr()),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Image(
                image: AssetImage('assets/images/coin.png'),
              ),
            ),
            const SizedBox(height: 20),
            Text(context.read<GameplayCubit>().state.levelPoints.toString(), style: theme.textTheme.bodyLarge),
            const Spacer(),         
            Badge(
                label: Text('ad'.tr(), style: Theme.of(context).textTheme.bodySmall),
                child: TextButton(
                        onPressed: () async => 
                        context.read<GameplayCubit>().showAds?
                        await context.read<GameplayCubit>().showInterstitialAd(context, context.read<GameplayCubit>().state.levelPoints)
                          :
                          {
                              context.read<GameplayCubit>().earnReward(context.read<GameplayCubit>().state.levelPoints),
                              Navigator.pop(context)
                          },
                        child: Text("collect".tr()),
                        )
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

}
