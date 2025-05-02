import 'package:hive_flutter/hive_flutter.dart';
import 'logging_reprository.dart';

class HiveRepository{

  final _log = LoggerReprository('HiveRepository');
  static const _preferencesBox = '_preferencesBox';
  static const _counterKey = '_counterKey';
  //final Box<Object> _box;

  //HiveRepository._(this._box);

  // static Future<HiveRepository> getInstance() async {
  //   final box = await Hive.openBox<Object>(_preferencesBox);
  //   return HiveRepository._(box);
  // }

  // T _getValue<T>(dynamic key, {T? defaultValue}) => _box.get(key, defaultValue: defaultValue) as T;

  // Future<void> _setValue<T>(dynamic key, T value) => _box.put(key, value);

  HiveRepository();
  /// initializing boxes
  Future<void> init(
    List<String> boxesNames,
    {List<TypeAdapter>? adapters}
  )async{
    _log.i('initializing hive...');
    await Hive.initFlutter();
    // Hive.registerAdapter<ChatMessage>(GeminiChatAdapter());
    // Hive.registerAdapter<AuthUser>(UserLocalAdapter());
    // Hive.registerAdapter<UserSession>(UserSessionAdapter());
    _log.i('initializing adapters...');
    if (adapters != null) {
      for (final adapter in adapters) {
        _log.i('Registering ${adapter.runtimeType} ...');
        Hive.registerAdapter(adapter);
      }
    }
    _log.i('initializing boxes...');
    for (var box in boxesNames){
      _log.i('loading $box...');
      if (!Hive.isBoxOpen(box)) {
        await Hive.openBox(box);
      } else {
        Hive.box(box);
      }
    }
    _log.i('Done...');  
  }
  
  Box getBox(String boxId) {
    return Hive.box(boxId);
  }
  
  Box<T> getTypedBox<T>(String boxId) {
    return Hive.box(boxId);
  }
  /// get data
  dynamic getData(Box<dynamic> box,String id) {
    _log.i('getting $id from ${box.name}...');
    return box.get(id);
  }
   /// get data
  dynamic getTypedData<T>(String boxId) {
    Box<T> box = getTypedBox<T>(boxId);
    _log.i('getting $T from ${box.name}...');
    return box.get(boxId);
  }
  /// get All data
  List<dynamic>? getAllData(Box<dynamic> box) {
    _log.i('getting all data from ${box.name}...');
    return box.values.toList();
  }  
  /// Clearing boxes
  Future<void> clearBox(Box<dynamic> box) async {
    _log.i('clearing $box...');
    await box.clear();
    _log.i('Done...');
  }
  /// put new box
  Future<void> putBoxData(Box<dynamic> box,String id,dynamic data) async {
    try {
      _log.i('putting $data to ${box.name}...');
      await box.put(id, data);
      _log.i('Done...');
    } catch (e) {
      _log.e('Error: $e');
    }
  }
  /// add new box
  Future<void> addBoxData(Box<dynamic> box,dynamic data) async {
    try {
      _log.i('putting $data to ${box.name}...');
      await box.add(data);
      _log.i('Done...');
    } catch (e) {
      _log.e('Error: $e');
    }
  }
  // remove put data
  Future<void> removeData(Box<dynamic> box,String id) async {
    if (!box.containsKey(id)) {
      _log.e('Error: Data not found'); 
      return;
    }
    try {
      _log.i('removing $id from ${box.name}...');
      await box.delete(id);
      _log.i('Done...');
    } catch (e) {
      _log.e('Error: $e');
    }
  }
  

  // Future<void> clearPreferencesBox() async {
  //   _log.i('clearing $preferencesBox...');
  //   await preferencesBox.clear();
  //   _log.i('Done...');
  // }

  // Future<void> clearUserData() async {
  //   _log.i('clearing $userBox...');
  //   await userBox.clear();
  //   _log.i('Done..');
  // }

  // Future<void> clearchatMessagesBox() async {
  //   _log.i('clearing $chatMessagesBox...');
  //   await chatMessagesBox.clear();
  //   _log.i('Done...');
  // }

  // Future<void> clearAllBoxes() async {
  //   _log.i('clearing $preferencesBox...');
  //   await preferencesBox.clear();
  //   _log.i('clearing $userBox...');
  //   await userBox.clear();
  //   _log.i('clearing $chatMessagesBox...');
  //   await chatMessagesBox.clear();
  //   _log.i('Done...');
  // }
  // // Saving boxes
  // Future<void> savePreferences(PreferencesKey prefKey,dynamic data) async {
  //   try {
  //     _log.i('putting $data to ${prefKey.name}...');
  //     await preferencesBox.put(prefKey.name, data);
  //     _log.i('Done...');
  //   } catch (e) {
  //     _log.e('Error: $e');
  //   }
  // }
  
  // Future<void> saveUserData(AuthUser data) async {
  //   try {
  //     _log.i('putting $data to ${PreferencesKey.userKey.name}...');
  //     await userBox.put(PreferencesKey.userKey.name, data);
  //     _log.i('Done...');
  //   } catch (e) {
  //     _log.e('Error: $e');
  //   }
  // }

  // Future<void> saveChatMessage(ChatMessage data) async {
  //   try {
  //   _log.i('putting $data to ${chatMessagesBox.name}...');
  //   await chatMessagesBox.add(data);
  //   _log.i('Done...');
  //   } catch (e) {
  //     _log.e('Error: $e');
  //   }
  // }
  // // Removing from boxes
  // Future<void> removePreferences(PreferencesKey prefKey) async {
  //   if (!preferencesBox.containsKey(prefKey.name)) {
  //     _log.e('Error: Data not found'); 
  //     return;
  //   }
  //   try {
  //     _log.i('removing ${prefKey.name}...');
  //     await preferencesBox.delete(prefKey.name);
  //     _log.e('Done...');
  //   } catch (e) {
  //     _log.e('Error: $e');
  //   }
  // }

  // Future<void> removeChatMessages(int messageKey) async {
  //   if (!chatMessagesBox.containsKey(messageKey)) {
  //     _log.e('Error: Data not found'); 
  //     return;
  //   }
  //   try {
  //     _log.i('removing $messageKey...');
  //     await chatMessagesBox.delete(messageKey);
  //     _log.e('Done...');
  //   } catch (e) {
  //     _log.e('Error: $e');
  //   }
  // }
  // // Getting from boxes
  // dynamic getPreference(PreferencesKey prefKey) {
  //   _log.i('getting $prefKey...');
  //   return preferencesBox.get(prefKey.name);
  // }

  // List<dynamic>? getAllPreference() {
  //   _log.i('getting all preferences...');
  //   return preferencesBox.values.toList();
  // }
  
  // AuthUser? getUser() {
  //   _log.i('getting ${PreferencesKey.userKey.name}...');
  //   return userBox.get(PreferencesKey.userKey.name);
  // }

  // ChatMessage? getChatMessage(int messageKey) {
  //   _log.i('getting $messageKey...');
  //   return chatMessagesBox.get(messageKey);
  // }

  // List<ChatMessage> getAllChatMessages() {
  //   _log.i('getting all chat messages...');
  //   return chatMessagesBox.values.toList();
  // }


}

