import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hseassist/blocs/blocs.dart';
import 'package:hseassist/pages/hunter_game_page.dart';
import '/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show PlatformDispatcher, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_options.dart';
import 'repository/logging_reprository.dart';
import 'service/authentication_service.dart';
import 'service/database_service.dart';
import 'service/notification_service.dart';
import 'service/preferences_service.dart';
import 'service/storage_service.dart';
final _log = LoggerReprository('main');

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  //localization
  _log.i('initializing localization...');
  await EasyLocalization.ensureInitialized();
  //initializing environment variables
  _log.i('initializing environment variables...');
  await _initEnvironmentVars();
  _log.i('Checking internet connection...');
  final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
  if (
    !connectivityResult.contains(ConnectivityResult.mobile) && 
    !connectivityResult.contains(ConnectivityResult.wifi) &&
    !connectivityResult.contains(ConnectivityResult.ethernet)
  ){
    runApp(NoInternetApp());
    return;
  }
  //initializing firebase
  _log.i('initializing firebaseApp...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  if (!kIsWeb) {
  FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
  };
}
  
  _log.i('initializing admob...');
  if (defaultTargetPlatform == TargetPlatform.android) {
    unawaited(MobileAds.instance.initialize());
    unawaited(
      MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ["9d09c570-8d45-4ce4-9991-edae9ef792e8"]))
    );
  }
  _log.i('initializing messaging...');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('Got a message whilst in the foreground!');
    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification}');
      debugPrint('Message data: ${message.data}');
      await _firebaseMessagingBackgroundHandler(message);
    }
  });
  //initializing services
  _log.i('initializing services...');
  final getIt = GetIt.instance;
  await _initServices(getIt);
  _log.i('getting local language...');
  final preferences = await getIt.getAsync<PreferencesService>(); // Now safe to access
  final lang = preferences.language;
  _log.i('initializing appliaction...');
  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
        //path: 'assets/translations/langs.csv',
        //assetLoader: CsvAssetLoader(),//const CodegenLoader(),
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        startLocale:lang == 'ar' ? const Locale('ar', 'EG') : const Locale('en', 'US'),
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AppCubit>(create: (context) => AppCubit()),
          ],
          //TODO : testing game
          child: AppMain(),//AppMain(),
        )),
  );
  _log.i('Done...');

}

Future<void> _initEnvironmentVars() async {
  // DotEnv dotenv = DotEnv() is automatically called during import.
  // If you want to load multiple dotenv files or name your dotenv object differently, you can do the following and import the singleton into the relavant files:
  // DotEnv another_dotenv = DotEnv()
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    _log.i('Error loading .env file: $e');
  }
}

Future<void> _initServices(GetIt getIt)async {
  _log.i('initializing services...');
  try {
    getIt.registerSingletonAsync<PreferencesService>(() async{ 
        _log.i('initializing PreferencesService...');
        final pref = PreferencesService();
        await pref.init();
        _log.i('Done...');
        return pref;
      }) ;
    getIt.registerSingletonAsync<AuthenticationService>(() async {
      _log.i('initializing AuthenticationService...');
      final prefs = getIt<PreferencesService>();
      final auth = AuthenticationService(prefs);
      _log.i('Done...');
      return auth;
    } ,
    dependsOn: [PreferencesService]
    );
    getIt.registerSingletonAsync<DatabaseService>(() async {
      _log.i('initializing DatabaseService...');
      final db = DatabaseService();
      _log.i('Done...');
      return db;
    } ,
    dependsOn: [PreferencesService]
    );
    getIt.registerLazySingleton<StorageService>(() { 
      _log.i('initializing StorageService...');
      final storage = StorageService();
      _log.i('Done...');
      return storage;
    });
    getIt.registerSingletonAsync<NotificationService>(() async{ 
      final notif = NotificationService();
      await notif.initialize();
      return notif;
    });
  } on Exception catch (e) {
    _log.e('$e');
  }
  
  _log.i('services initialized...');
  if (defaultTargetPlatform != TargetPlatform.android ) {
    _log.i('initializing Firebase Emulator...');
    const emulatorPortAuth = 9099;
    const emulatorPortFdb = 8080;
    const emulatorPortStoreage = 9199;
    const emulatorPortFunctions = 5001;
    const emulatorPortPubSub = 8085;
    final emulatorHost =(!kIsWeb && defaultTargetPlatform == TargetPlatform.android)? '10.0.2.2': 'localhost';
    try {      
      FirebaseAuth.instance.useAuthEmulator(emulatorHost, emulatorPortAuth);
      FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, emulatorPortFdb);
      await FirebaseStorage.instance.useStorageEmulator(emulatorHost, emulatorPortStoreage);
      FirebaseFunctions.instance.useFunctionsEmulator(emulatorHost, emulatorPortFunctions);
      _log.i('Done...');
    } catch (e) {
      _log.e(e);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  _log.i('RemoteMessage recieved $message...');
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _log.i("Handling a background message: ${message.messageId}");
  final notification = NotificationService();
  final nottification = message.notification;
  if(nottification !=null && nottification.body !=null) {
    notification.showNotification(nottification.title??'new message', nottification.body!);
  }
  _log.i('Done...');
}

class NoInternetApp extends StatelessWidget {
  const NoInternetApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.wifi_off, size: 64,),
              Text(
                "errorMessages.noInternet".tr(),
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 5,
              ),
            ],

          ),
        ),
      ),
    );
  }
}
