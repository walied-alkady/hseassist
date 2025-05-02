import 'dart:async' show StreamController, StreamSubscription;
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/blocs/manager.dart';
import 'package:hseassist/models/models.dart';
import 'package:hseassist/service/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../enums/authentication status.dart';
import '../enums/user_role.dart';
import '../repository/admob_repositroy.dart';
import '../repository/logging_reprository.dart';
import 'package:hseassist/theme.dart';

class AppState extends Equatable{
  const AppState({
    this.appLifecycleState = AppLifecycleState.resumed,
    this.contentMessage = '',
    this.gotAnswerResponse = 'Type a message',
    this.chatMessages = const [],
    this.isLoadingMessage = false,
    this.isRecordingVoidMessage = false,
    this.isSpeachAvailable = false,
    this.themeData,
    this.authenticationStatus = AuthenticationStatus.unauthenticated,
    this.currentUser,
    this.currentWorkplaceId,
    this.currentRole,
    this.isCurrentUserMaster,
    this.isAdmin,
  });

  final AppLifecycleState appLifecycleState;
  final String contentMessage;
  final String gotAnswerResponse;
  final List<ChatMessage> chatMessages;
  final bool isLoadingMessage;
  final bool isRecordingVoidMessage;
  final bool isSpeachAvailable;
  final ThemeData? themeData;
  final AuthenticationStatus authenticationStatus;
  final AuthUser? currentUser; 
  final String? currentWorkplaceId; 
  final String? currentRole; 
  final bool? isCurrentUserMaster;
  final bool? isAdmin;
  @override
  List<Object?> get props => [
        appLifecycleState,
        contentMessage,
        gotAnswerResponse,
        chatMessages,
        isLoadingMessage,
        isRecordingVoidMessage,
        isSpeachAvailable,
        themeData,
        authenticationStatus,
        currentUser,
        currentWorkplaceId,
        currentRole,
        isCurrentUserMaster,
        isAdmin,
      ];

  AppState copyWith({
    AppLifecycleState? appLifecycleState,
    String? contentMessage,
    String? gotAnswerResponse,
    List<ChatMessage>? chatMessages,
    bool? isLoadingMessage,
    bool? isRecordingVoidMessage,
    bool? isSpeachAvailable,
    ThemeData? themeData,
    AuthenticationStatus? authenticationStatus,
    AuthUser? currentUser,
    String? currentWorkplaceId,
    String? currentRole,
    bool? isCurrentUserMaster,
    bool? isAdmin,
  }) {
    return AppState(
      appLifecycleState: appLifecycleState ?? this.appLifecycleState,      
      contentMessage: contentMessage ?? this.contentMessage,
      gotAnswerResponse: gotAnswerResponse ?? this.gotAnswerResponse,
      chatMessages: chatMessages ?? this.chatMessages,
      isLoadingMessage: isLoadingMessage ?? this.isLoadingMessage,
      isRecordingVoidMessage: isRecordingVoidMessage ?? this.isRecordingVoidMessage,
      isSpeachAvailable: isSpeachAvailable ?? this.isSpeachAvailable,
      themeData: themeData ?? this.themeData,
      authenticationStatus: authenticationStatus ?? this.authenticationStatus,
      currentUser: currentUser ?? this.currentUser,
      currentWorkplaceId: currentWorkplaceId ?? this.currentWorkplaceId,
      currentRole: currentRole ?? this.currentRole,
      isCurrentUserMaster: isCurrentUserMaster ?? this.isCurrentUserMaster,
      isAdmin: isAdmin ?? this.isAdmin,
      
    );
  }
}

class AppCubit extends Cubit<AppState> with Manager<AppCubit>{
  final _log = LoggerReprository('AppCubit');


  AppCubit() : super(const AppState());
  final _authenticationStatusController =
      StreamController<AuthenticationStatus>.broadcast();

  Stream<AuthenticationStatus> get authenticationStatusStream =>
      _authenticationStatusController.stream;
  // general fields

  late final AppLifecycleListener listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
      // onDetach: _onDetach,
      // onHide: _onHide,
      // onInactive: _onInactive,
      // onPause: _onPause,
      // onRestart: _onRestart,
      // onResume: _onResume,
      // onShow: _onShow,
      //onExitRequested: 
    ); 
  
  bool get isMobile => (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  AuthenticationStatus get userAuthStatus {
    if(FirebaseAuth.instance.currentUser !=null){
      return AuthenticationStatus.authenticated;
    }else{
      return AuthenticationStatus.unauthenticated;
    }
  }
  // interstitial ad settings
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
  // ai messaging  
  final stt.SpeechToText _speech = stt.SpeechToText();
  get isSpeechAvailable => _speech.isAvailable;
  String _currentLocaleId = '';
  String _accumulatedText = '';
  
  // Methods

  Future<void> init() async {
    _checkAuthenticationStatus();

    // Check the status when the user log in or log out
    FirebaseAuth.instance.authStateChanges().listen((event) {
      _checkAuthenticationStatus();
      if (event != null){
            getNewAuthenticatedUser(event.uid);
      }
    });

    bool available = await _speech.initialize(
              onStatus: (status) {
              // Handle status changes (e.g., listening, not listening)
              switch (status) {
                case "listening":
                  emit(state.copyWith(isRecordingVoidMessage: true)); // Set recording state to true
                  break;
                case "notListening":
                  emit(state.copyWith(isRecordingVoidMessage: false));// Set recording state to true
                  break;
                default:
                  emit(state.copyWith(isRecordingVoidMessage: false));
                  break;
              }

              _log.i('Speech recognition status: $status');

            },
            onError: (error) => _log.e('Speech recognition error: $error'), // Handle initialization errors
          );
          if (available) {
            _currentLocaleId = await _speech.systemLocale().then((res)=> res?.localeId ?? 'en_US'); // Get system locale if available
            // You could also let the user select a locale here
          }

  }
  //
  Future<void> updateUserInformation(AuthUser user,String workPlaceId, String userRole) async {
    emit(state.copyWith(
      currentUser: user,
      currentWorkplaceId: workPlaceId,
      currentRole: userRole,
      isAdmin: user.currentWorkplaceRole == UserRole.admin.name,
      isCurrentUserMaster: user.currentWorkplaceRole == UserRole.master.name,
    ));
  }
  
  Future<void> getNewAuthenticatedUser(String uid) async {
    try {
      _log.i('getting user with id : $uid');
      final gotUser = await db.findOneByField<AuthUser>('uid',uid); 
      if(gotUser == null){
        _log.i('getting user with email : ${gotUser?.email}');
        return;
      }else{
        _log.i('couldnt get user');
        updateUserInformation(gotUser, gotUser.currentWorkplace!, gotUser.currentWorkplaceRole!);
        return;
      }
    } catch (e) {
      _log.e('Error fetching authenticated user: $e');
      return;
    }
  }
  
  void _checkAuthenticationStatus() {
    final user = FirebaseAuth.instance.currentUser;
    final status = user != null
        ? AuthenticationStatus.authenticated
        : AuthenticationStatus.unauthenticated;
    // Add the new status to the stream
    _authenticationStatusController.add(status);
    // update the current state
    emit(state.copyWith(authenticationStatus: status));
    //get current user data
    if (user != null){
      getNewAuthenticatedUser(user.uid);
    }

  }

  void clearUserData() {
    emit(state.copyWith(
      currentUser: null,
      currentWorkplaceId: null,
      currentRole: null,
      isAdmin: false,
      isCurrentUserMaster: false,
    ));
  }


  void updateTheme(ThemeData theme){
    bool isDarkTheme = ( 
        theme == safetyThemeDarkOrange ||
        theme == safetyThemeDarkGreen || 
        theme == safetyThemeDarkHighVisibility
    );
    //context.read<AppCubit>().prefs.setIsDarkTheme(isDarkTheme);
    emit(state.copyWith(
      themeData: theme
    ));
  }
  // lifecycle monitor
  Future<void> _onStateChanged(AppLifecycleState appState) async {
    switch (appState) {
      case AppLifecycleState.detached:
        _log.i('detached');
        emit(state.copyWith(appLifecycleState:AppLifecycleState.detached));
      case AppLifecycleState.resumed:
        _log.i('resumed');
        if(prefs.userLoggedOffTime != null) {
            _log.i('Last session duration: ${prefs.sessionDuration}'); 
            prefs.setUserJustLoggedIn();
        }
      emit(state.copyWith(appLifecycleState:AppLifecycleState.resumed));
      case AppLifecycleState.inactive:
        _log.i('inactive');
        emit(state.copyWith(appLifecycleState:AppLifecycleState.inactive));
      case AppLifecycleState.hidden:
        _log.i('hidden');
        emit(state.copyWith(appLifecycleState:AppLifecycleState.hidden));
      case AppLifecycleState.paused:
      _log.i('paused');
      // return;
      //   //TODO check session implementation
      //   if(session != null) {
      //       session.logoutTime = DateTime.now();
      //       await session.save();
      //   }
      //   //calculating user points
      //   int usrPoints = prefs.getPoints();
      //   final sessionDuration = session?.duration??Duration();
      //   final settings = await db.findAll<WorkplaceSetting>().then((sett) => sett.first);
      //   // adding usage points
      //   if(sessionDuration.inMinutes > 1){
      //     usrPoints = usrPoints + settings.appUsageDurationPoints;
      //   }
      //   final curWp = prefs.currentUser;
      //   db.updateOne<UserWorkplace>(curWp!.currentWorkplaceDataId??'', {
      //     UserWorkPlaceFields.points.name: usrPoints,
      //   });
      //   //adding create hazard points
      //   await authService.logOut();
      //   emit(state.copyWith(appLifecycleState:AppLifecycleState.paused));
    }
  }
  // AI messaging
  void sendChatMessage(String text) async {
    emit(state.copyWith(isLoadingMessage: true));
    try {
          // if (state.contentMessage.isNotEmpty) {
          //   emit(state.copyWith(chatMessages: gemini.cachChatMessaging,contentMessage: ''));
          //   log.i('got response...');
          //   final senderChat = GeminiChat(
          //         id: (gemini.cachChatMessaging.length + 1).toString(),
          //         workplace: authService.currentDbUser.currentWorkplace!,
          //         time: DateTime.now(),
          //         message: text,
          //         fromAssistant: false,
          //         loading: false
          //     );
          //   log.i('saving sender data to cach...');  
          //   gemini.cachChatMessaging.add(senderChat); 
          //   emit(
          //       state.copyWith(
          //         chatMessages :gemini.cachChatMessaging,
          //         gotAnswerResponse : 'geminiTypeMessage'.tr(),
          //       )
          //     );
          //   final recieverChatTemp = GeminiChat(
          //           id: (gemini.cachChatMessaging.length + 1).toString(),
          //           workplace: authService.currentDbUser.currentWorkplace!,
          //           time: DateTime.now(),
          //           message: '...',
          //           loading: true,
          //           fromAssistant: true,
          //         );
          //   log.i('saving temp response data to cach...');  
          //   gemini.cachChatMessaging.add(recieverChatTemp);  
          //   emit(
          //       state.copyWith(
          //         chatMessages :gemini.cachChatMessaging,
          //       )
          //     ); 
          //   final res  =await gemini.sendChatMessage(text);
          //   gemini.cachChatMessaging.removeWhere((item) => item.id == recieverChatTemp.id);
          //   log.i('saving response data to cach...');  
          //   final recieverChat = GeminiChat(
          //           id: (gemini.cachChatMessaging.length + 1).toString(),
          //           workplace: authService.currentDbUser.currentWorkplace!,
          //           time: DateTime.now(),
          //           message: res.text?.trim() ?? '...',
          //           loading: false,
          //           fromAssistant: true,
          //         );
          //   gemini.cachChatMessaging.add(recieverChat);  
          //   emit(
          //     state.copyWith(
          //       chatMessages :gemini.cachChatMessaging,
          //       gotAnswerResponse : 'geminiTypeMessage'.tr(),
          //     )
          //   );
          // }
    } on Exception catch (e) {
      _log.e(e);
    }finally{
        emit(state.copyWith(
          isLoadingMessage : false,
          ));
    }

  }

  Future<void> startVoiceRecording() async {
    if (state.isSpeachAvailable && !state.isRecordingVoidMessage) { // Check if already listening
      emit(state.copyWith(isRecordingVoidMessage: true));
      _accumulatedText = ''; // Reset accumulated text
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _accumulatedText = result.recognizedWords;
            stopVoiceRecording();
            sendChatMessage(_accumulatedText.trim());
            emit(state.copyWith(isRecordingVoidMessage: false));
            // Process the final recognized words
          } else {
            emit(state.copyWith(contentMessage: result.recognizedWords)); // Update UI with partial results
          }
        },
        //listenFor: const Duration(seconds: 30),
        localeId: _currentLocaleId,
      );
    }
  }

  Future<void> stopVoiceRecording() async {
      await _speech.stop();
      emit(state.copyWith(isRecordingVoidMessage: false));
  }

  void updateChatCach(){
    emit(state.copyWith(chatMessages: gemini?.cachChatMessages));
  }
  // ads  
  Future<void> createInterstitialAd() async {
    await InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(
          // keywords: <String>['foo', 'bar'],
          // contentUrl: 'http://foo.com/bar.html',
          // nonPersonalizedAds: true,
        ),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _log.i('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _log.i('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }
  
  Future<void> showInterstitialAd(BuildContext context) async{
    if (_interstitialAd == null) {
      _log.i('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          _log.i('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _log.i('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        _log.i('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
      onAdWillDismissFullScreenContent: (ad) {
       ad.dispose(); // Dispose of the ad to release resources.
      Navigator.pop(context);
    }
      
    );
    if(_interstitialAd!=null){
      await _interstitialAd!.show();
    }
  }

   // image
  Future<File?> pickImage({ImageSource  imageSource= ImageSource.camera}) async { 
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: imageSource);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

}
