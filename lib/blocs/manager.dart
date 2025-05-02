import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hseassist/repository/logging_reprository.dart';
import 'package:image_picker/image_picker.dart';

import '../repository/admob_repositroy.dart';
import '../service/authentication_service.dart';
import '../service/database_service.dart';
import '../service/gemini_service.dart';
import '../service/preferences_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../service/storage_service.dart';

mixin Manager<T>{
  final GetIt serviceLocator = GetIt.instance;
  late final AuthenticationService _authService = serviceLocator<AuthenticationService>();
  late final DatabaseService _db = serviceLocator<DatabaseService>();
  late final PreferencesService _prefs = serviceLocator<PreferencesService>();
  late final GeminiService _gemini  = serviceLocator<GeminiService>();
  late final StorageService _storage = serviceLocator<StorageService>();
  final _log = LoggerReprository('Manager');
  
  AuthenticationService get authService => _authService;
  DatabaseService get db => _db;
  StorageService get storage => _storage;
  PreferencesService get prefs => _prefs;
  GeminiService? get gemini => _gemini;
  
  String get className => T.toString();
  
  // interstitial ad settings
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
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

 // points
  
 // AI  
  Future<void> initGeminiService() async {
    try {
      if (serviceLocator.isRegistered<GeminiService>() && serviceLocator.isReadySync<GeminiService>() ) serviceLocator.unregister<GeminiService>(); 
      _log.i('loading GeminiService...');
      serviceLocator.registerSingletonAsync<GeminiService>(() async {
        _log.i('initializing GeminiService...');
        final gemService = GeminiService(db,prefs);
        await gemService.init();
        _log.i('GeminiService initialized...');
        return gemService;
      } ,
      dependsOn: [DatabaseService,PreferencesService],
      );
      _log.i('await GeminiService to be ready...');
      //final geminiService = await _getit.getAsync<GeminiService>(); // Await here!
      await serviceLocator.isReady<GeminiService>(timeout: Duration(seconds: 15)); 
      _log.i('GeminiService initialized...' );
    } on WaitingTimeOutException catch (e){
      _log.e('${e.notReadyYet}' );
    } on Exception catch (e) {
      _log.e('$e' );
    }
  } 

  // Future<bool> isSupportedAndroidVersion() async {
  // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  // int sdkInt = androidInfo.version.sdkInt;

  // //Example: Require Android 6.0 (API level 23) or higher
  // if (sdkInt >= 23) {
  //   return true;
  // } else {
  //   return false;
  // }
  // }
}