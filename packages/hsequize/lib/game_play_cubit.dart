import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'enums.dart';
import 'models/quiz_category.dart';
import 'models/quize.dart';
import 'models/user_data.dart';
import 'screens/gameplay.dart';
import 'screens/levelcomplete.dart';
import 'screens/levelfailed.dart';
import 'widgets/dialogue_frame.dart';
import 'widgets/full_screen_model.dart';

typedef EventActionCallback = void Function(BuildContext, QuizEventAction);


class GameplayState extends Equatable {

  final List<QuizCategory>? quizCategories;
  final QuizCategory? selectedQuizCategory;
  final List<Quiz>? categoryQuizzes;
  final Quiz? selectedQuiz;
  final int completedCount;
  final bool isAnswerPressed;
  final int points;
  final int levelPoints;
  final List<int> userLevel;
  final List<bool> quizeLocks;

  const GameplayState({
      this.quizCategories,
      this.selectedQuizCategory,
      this.categoryQuizzes,
      this.selectedQuiz,
      this.completedCount = 0,
      this.isAnswerPressed = false,
      required this.points,
      this.levelPoints = 0,
      required this.userLevel,
      required this.quizeLocks, 
  });

  @override
  List<Object?> get props => [quizCategories, selectedQuizCategory, categoryQuizzes,selectedQuiz,completedCount,isAnswerPressed,points,userLevel,quizeLocks,levelPoints];

  GameplayState copyWith({
    List<QuizCategory>? quizCategories,
    QuizCategory? selectedQuizCategory,
    List<Quiz>? categoryQuizzes,
    Quiz? selectedQuiz,
    int? completedCount,
    bool? isAnswerPressed,
    int? levelPoints,
    int? points,
    List<int>? userLevel,
    List<bool>? quizeLocks,
  }) {
    return GameplayState(
      quizCategories: quizCategories ?? this.quizCategories,
      selectedQuizCategory: selectedQuizCategory ?? this.selectedQuizCategory,
      categoryQuizzes: categoryQuizzes ?? this.categoryQuizzes,
      selectedQuiz: selectedQuiz ?? this.selectedQuiz,
      completedCount: completedCount ?? this.completedCount,
      isAnswerPressed: isAnswerPressed ?? this.isAnswerPressed,
      levelPoints: levelPoints ?? this.levelPoints,
      points: points ?? this.points,
      userLevel: userLevel ?? this.userLevel,
      quizeLocks: quizeLocks ?? this.quizeLocks,
    );
  }
}

class GameplayCubit extends Cubit<GameplayState> {
    /// This will be the quiz data that you have to provide
  final List<QuizCategory> quizCategories;

  /// [onTapEvent] will be call on every event preformed by the user
  //final EventActionCallback? onTapEvent = ;
  /// 
  final UserData _userData;

  // interstitial ad settings
  final String? _interstitialAdId;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
  // banner ad settings
  final String? _bannerAddId;
  final bool showAds;
  final String _lang;
  // user level and points

  GameplayCubit({
    required this.quizCategories,
    required UserData userData,
    String? bannerAddId,
    String? interstitialAdId , 
    this.showAds = true,
    String lang = 'en'
    }) : _userData = userData, _interstitialAdId = interstitialAdId, _lang = lang, _bannerAddId = bannerAddId, 
                        super( GameplayState(
                                          quizCategories: null,
                                          selectedQuizCategory: null,
                                          categoryQuizzes: null,
                                          selectedQuiz: null,
                                          completedCount: 0,
                                          isAnswerPressed: false,
                                          points : userData.points,
                                          userLevel: userData.quizeLevelsAvailable.values.map((value) => value == 1 ? 1 : 0).toList(),
                                          quizeLocks: userData.quizeLevelsAvailable.values.map((value) => value == 0 ? true : false).toList(),
                                          )
                        );


  Future<void> loadUserGameData() async {
    try {
      
      debugPrint('Fetching game data...');
      if(showAds) {
        _createInterstitialAd();
      }
      emit(state.copyWith(
        points: _userData.points,
        userLevel:_userData.quizeLevelsAvailable.values.map((value) => value == 1 ? 1 : 0).toList(),
        quizeLocks: _userData.quizeLevelsAvailable.values.map((value) => value == 0 ? true : false).toList(),
      ));
    } catch (e) {
      debugPrint('Error loading user game data: $e');
    }
  }
  
  // void getQuizCategories(List<QuizCategory> categories) {
  //   //categories.shuffle();
  //   final quizCategories = categories.toList();
  //   emit(
  //     state.copyWith(
  //     quizCategories: quizCategories,
  //   ));
  // }

  void onSelectQuizCategory(QuizCategory e) {
    emit(
      state.copyWith(
        selectedQuizCategory: e,
    ));
  }
  
  void startPlay(BuildContext context){
    if(state.selectedQuizCategory== null){
      return;
    }else{
      final catIndex = quizCategories.indexOf(state.selectedQuizCategory!);
    final quizes = state.selectedQuizCategory?.quizzes
      .where((quiz) => quiz.level.number <= state.userLevel[catIndex]).toList();
    quizes?.shuffle();
    final categoryQuizzes = quizes?.take(3).toList();
    //getQuizCategories(quizCategories);
    deductPlayCost();
    //onNextQuestion(context);
    emit(
      state.copyWith(
        isAnswerPressed: false,
        completedCount: 0,
        categoryQuizzes: categoryQuizzes,
        selectedQuiz: categoryQuizzes?[0],
    ));
    bool isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
        if(isMobile){
          debugPrint('Now loading banner...');
          if(isMobile) {
            _createInterstitialAd();
            debugPrint('Loading banner done...');
          }else{
              debugPrint('not mobile...');
          }
          
        }
    Navigator.pushNamed(context, QuizGameplayScreen.routeName);
    }
    
  }

  // void onNextQuestion(BuildContext context) {
  //   emit(
  //     state.copyWith(
  //       isAnswerPressed: false,
  //       selectedQuiz: state.categoryQuizzes?[state.completedCount],
  //   ));
  //   //Navigator.pushReplacementNamed(context, QuizGameplayScreen.routeName);
  // }

  void onTapAnswer(BuildContext context, String selectedAnswer) {
    const duration = Duration(seconds: 1);
    emit(
      state.copyWith(
        isAnswerPressed: true,
    ));

    final currentQuiz = state.categoryQuizzes?[state.completedCount];
    final correctAnswer = currentQuiz?.options[currentQuiz.correctIndex];
    if (selectedAnswer != correctAnswer) {
      levelEnd(context);
    } else {
      if (state.completedCount < state.categoryQuizzes!.length-1) {
        Future.delayed(duration,() {
          //onNextQuestion(context);
          final completedCounts = state.completedCount+1;
          emit(
            state.copyWith(
              completedCount: completedCounts,
              isAnswerPressed: false,
              selectedQuiz: state.categoryQuizzes?[completedCounts],
            ));
            }
        );
      } else {
        final levelPoints = state.selectedQuiz?.level.pointsGained;
        emit(state.copyWith(levelPoints: levelPoints));
        Future.delayed(
            duration,
            () {
              if(context.mounted) {
                Navigator.pushReplacementNamed(context, LevelCompleteScreen.routeName);
              }
            });
      }
    }
  }

  // void updateIsAnswered(bool isAnsewered){
  //   emit(
  //     state.copyWith(
  //     isAnswerPressed: isAnsewered,
  //   ));
  // }

  void earnReward(int levelPoints) {
    emit(
      state.copyWith(
        points: state.points + levelPoints,
    ));
  }

  void deductPlayCost() {
    
    if (state.points <= 0) {
      return;
    }
    emit(
      state.copyWith(
        points: state.points - 10,
    ));
  }

  //TODO: complete the rest
  void unlockWithPoints(BuildContext context, String categoryNameToUnlock) {
    if (state.points <= 0) {
      Navigator.of(context).pushReplacement(
        FullScreenModal(
          body: DialogFrame(
            title: 'Sorry',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Sorry you do not have enough poits. Please Try Later !!!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                )
              ],
            ),
          ),
        ),
      );
    } else {
      emit(
      state.copyWith(
        points: state.points - 200,
    ));
      // prefs.updatePoints(state.points);
      // prefs.unlockedCategory(categoryNameToUnlock);
      Navigator.pop(context);
    }
  }

  void levelEnd(BuildContext context) {
    const duration = Duration(seconds: 1);
    //final currentTime = DateTime.now();

    //final lastLifeUsedTime = prefs.getLastLifeUsedTime();
    Future.delayed(
          duration,
          () => Navigator.pushReplacementNamed( context, LevelFailedScreen.routeName));

    // if (currentTime.difference(lastLifeUsedTime).inMinutes >= 5) {
    //   Future.delayed(
    //       duration,
    //       () => Navigator.pushNamed( context, ExtraTryScreen.routeName));
    // } else {
    //   Future.delayed(
    //       duration,
    //       () => Navigator.pushReplacementNamed( context, LevelFailedScreen.routeName));
    // }
  }

  void continueOnLevelFailed(BuildContext context) {
    //onTapEvent?.call(context, QuizEventAction.continueWithPoints);
    emit( state.copyWith(isAnswerPressed: false));      
    if (state.points <= 0 || state.points < 20) {
      Navigator.of(context).pushReplacement(
        FullScreenModal(
          body: DialogFrame(
            title: 'sorry'.tr(),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  'sorryMessage'.tr(),//'Sorry you do not have enough points. Please Try Later !!!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                )
              ],
            ),
          ),
        ),
      );
    } else {
      emit(
      state.copyWith(
        points: state.points - 20,
    ));
      Navigator.pushReplacementNamed(context, QuizGameplayScreen.routeName);
    }
  }

  // ads  
  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: _interstitialAdId??"",
        request: const AdRequest(
          // keywords: <String>['foo', 'bar'],
          // contentUrl: 'http://foo.com/bar.html',
          // nonPersonalizedAds: true,
        ),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }
  
  Future<void> showInterstitialAd(BuildContext context,int points) async{
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdWillDismissFullScreenContent: (ad) {
        earnReward(points);
       ad.dispose(); // Dispose of the ad to release resources.
      Navigator.pop(context);
    }
    );
    await _interstitialAd!.show();
  }

}