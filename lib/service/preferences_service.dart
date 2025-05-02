import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hseassist/models/models.dart';
import '../enums/preference_key.dart';
import '../models/user_session.dart';
import '../repository/hive_repository.dart';
import '../repository/logging_reprository.dart';
import '../repository/secure_storage_repository.dart';

class PreferencesService {
  
  final SecureStorageRepository _secure = SecureStorageRepository();
  final HiveRepository  _hiveRepository = HiveRepository ();

  final _log = LoggerReprository('PreferencesService');
  PreferencesService();

  Future<void> init() async{
    const List<String> boxesNames = [
      'preferences',
      // 'UserLocal',
      // 'chatMessagesBox',
      // 'sessionBox'
    ];
    // final adapters = <TypeAdapter>[
    //   GeminiChatAdapter(),
    //   UserLocalAdapter(),
    //   UserSessionAdapter()
    //   // Add more adapters here as needed...
    // ];
    await _hiveRepository.init(boxesNames);
  }
  
  Box _getPreferenceBox() => _hiveRepository.getBox('preferences');

  // Notification
  bool get isEnableNotifcations => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.enableNotifications.name)??false;
  Future<void> setEnableNotifcations(bool value) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.enableNotifications.name, value);
  }
  //----- User data---------
  String get currentUserId => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.currentUserId.name)??'';
  Future<void> setCurrentUserId(String value) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.currentUserId.name, value);
  }
  
  //----- User session---------
  bool get isFirstLogin => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.isFirstLogin.name)??false;
  Future<void> setIsFirstLogin(bool value) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.isFirstLogin.name, value);
  }
  bool get isUserLoggedin => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.userIsLoggedin.name)??false;
  Future<void> setUserIsLoggedin(bool value) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.userIsLoggedin.name, value);
  }
  DateTime get userLoggedInTime => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.userLoginTime.name)??false;
  Future<void> setUserLoggedInTime(DateTime value) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.userLoginTime.name, value);
  }
  DateTime? get userLoggedOffTime => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.userLoggedOffTime.name)??false;
  Future<void> setUserLoggedOffTime(DateTime? value) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.userLoggedOffTime.name, value);
  }
  Future<void> setUserJustLoggedIn() async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.userLoggedOffTime.name, DateTime.now());
    await _hiveRepository.removeData(_getPreferenceBox(),PreferencesKey.userLoggedOffTime.name);
  }
  Duration get sessionDuration => userLoggedOffTime != null ? userLoggedOffTime!.difference(userLoggedInTime) : Duration.zero;
  //-----Interface
  Future<void> setTheme(bool isDark) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.themeMode.name, isDark);
  }
  
  bool get isDarkTheme => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.themeMode.name)??false;
  //language
  Future<void> setlanguage(String language) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.language.name, language);
  }
  String get language => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.language.name)??LanguageCodes.enUS;
  
  // tutorials
  Future<void> setFirstTimeHome(bool val) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.firstTimeHomePage.name, val);
  }
  bool get firstTimeHome => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.firstTimeHomePage.name)??true;
  
  Future<void> setFirstTimeHomeFab(bool val) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.firstTimeHomeFabPage.name, val);
  }
  bool get firstTimeHomeFab => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.firstTimeHomeFabPage.name)??true;
  
  Future<void> setFirstTimeHazardCreate(bool val) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.firstTimeHazardCreatePage.name, val);
  }
  bool get firstTimeHazardCreate => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.firstTimeHazardCreatePage.name)??true;

  Future<void> setFirstTimeIncidentCreate(bool val) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.firstTimeIncidentCreatePage.name, val);
  }
  bool get firstTimeIncidentCreate => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.firstTimeIncidentCreatePage.name)??true;

  Future<void> setFirstTimeTaskCreate(bool val) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.firstTimeTaskCreatePage.name, val);
  }
  bool get firstTimeTaskCreate => _hiveRepository.getData(_getPreferenceBox(),PreferencesKey.firstTimeTaskCreatePage.name)??true;

  Future<void> setResetTutorials([bool val=true]) async{
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.firstTimeHomePage.name, val);
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.firstTimeHomeFabPage.name, val);
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.firstTimeHazardCreatePage.name, val);
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.firstTimeIncidentCreatePage.name, val);
    await _hiveRepository.putBoxData(_getPreferenceBox(),PreferencesKey.firstTimeTaskCreatePage.name, val);
  }
 //---------- secure storege
 //TODO: bypass for web
  Future<dynamic> readSecure(String key) async {
    _log.i('getting $key...');
    if(!kIsWeb) {
      return await _secure.storage.read(key: key);
    }
  }
  
  Future<void> writeSecure({required String key,required String value}) async {
    if(!kIsWeb) {
      await _secure.storage.write(key: key, value: value);
    }
  }
  
  Future<void> deleteSecure(String key) async {
    if(!kIsWeb) {
      await _secure.storage.delete(key: key);
    }
  }

}

class LanguageCodes{
  static const String arEG = 'ar-EG';
  static const String enUS = 'en-US';
}