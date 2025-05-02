
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hsequize/enums.dart';
import 'package:hsequize/game_play_cubit.dart';
import 'package:hsequize/widgets/base_scafold.dart';
import 'package:hsequize/widgets/label_header.dart';

class LevelFailedScreen extends StatelessWidget {
  static const routeName = '/LevelFailedScreen';

  const LevelFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameplayCubit>();
    final theme = Theme.of(context);
    // Future.delayed(
    //     const Duration(seconds: 1),
    //     () => cubit
    //         .onTapEvent
    //         ?.call(context, QuizEventAction.levelFailed)
    // );

    return BaseScaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LabelHeader(title: "tryAgainLater".tr()),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Image(
                image: AssetImage('assets/images/logo.jpg'),
              ),
            ),
            const SizedBox(height: 20),
            Text( 'loosRewardsMessage'.tr(),   //'Stop now and lose your rewards',
                style: theme.textTheme.titleLarge),
            const Spacer(),
            TextButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: Text('endQuize'.tr()),
            ),
            Badge(
                label: Row(
                  children: [
                    // const Image(
                    //   image: AssetImage('assets/images/diamond.png'),
                    //   height: 15,
                    // ),
                    Text('points20'.tr() ,//'20 Points', 
                    style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                child: TextButton(
                          onPressed:  () => cubit.continueOnLevelFailed(context),
                          child: Text("continue".tr()),
                        )
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
