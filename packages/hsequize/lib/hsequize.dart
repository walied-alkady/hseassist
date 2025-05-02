
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hsequize/models/user_data.dart';

import 'data.dart';
import 'game_play_cubit.dart';
import 'models/quiz_category.dart';
import 'screens/gameplay.dart';
import 'screens/levelcomplete.dart';
import 'screens/levelfailed.dart';
import 'screens/menue.dart';


class QuizeGame extends StatelessWidget {
  /// [_quizCategories] List of quizes categories
  final List<QuizCategory> _quizCategories = quizeData;
  final String? _interstitialAdUnitId;
  final String? _bannerAddId;
  final UserData _userData;
  final bool _showAds;
  /// [_lang] is either 'ar' or 'en' default is 'en'
  final String _lang;
  QuizeGame({
    super.key, 
    // required this.menuLogoPath,
    required UserData userData,
    String? interstitialAdUnitId,
    String? bannerAddId,
    String lang = 'en',
    bool showAds = true
  }) : _lang = lang, _bannerAddId = bannerAddId, _interstitialAdUnitId = interstitialAdUnitId, _showAds = showAds, _userData = userData;
  
  @override
  Widget build(BuildContext context) {
    return  BlocProvider<GameplayCubit>(
        create: (BuildContext context) => GameplayCubit(
          quizCategories :_quizCategories,
          userData : _userData,
          bannerAddId:_bannerAddId,
          interstitialAdId:_interstitialAdUnitId,
          showAds :_showAds,
          lang: _lang
          ),
        child: QuizeGameMain(),
    );
  }

}

class QuizeGameMain extends StatelessWidget {
  const QuizeGameMain({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Navigator(
                          initialRoute: MenuScreen.routeName,
                          onGenerateRoute: (settings) {
                            switch (settings.name) {
                              case MenuScreen.routeName:
                                return MaterialPageRoute(builder: (_) => MenuScreen());
                              case QuizGameplayScreen.routeName:
                                return MaterialPageRoute(builder: (_) => QuizGameplayScreen());
                              case LevelCompleteScreen.routeName:
                                return MaterialPageRoute(builder: (_) => LevelCompleteScreen());
                              case LevelFailedScreen.routeName:
                                return MaterialPageRoute(builder: (_) => LevelFailedScreen());
                            }
                            return null;
                          },
                    );
            }
            return const Center(child: CircularProgressIndicator.adaptive());
          },
          future: context.read<GameplayCubit>().loadUserGameData(),
        );
  }
}
