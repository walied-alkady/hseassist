import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../enums/form_status.dart';


import '../repository/logging_reprository.dart';
import 'manager.dart';

// enum AppThemeTypes { light, dark }


class AppSetts{
  static const theme = 'darkMode';
  static const language = 'AppLanguage';
  static const enableNotifcations = 'isEnableNotifcations';
}
//states
class SettingsStates extends Equatable {
  final String language;
  final bool isDarkmode;
  final bool isEnableNotifcations;
  final int activeTab;
  
  final FormStatus status;
  final String? errorMessage;

  const SettingsStates({
    this.language = '',
    this.isDarkmode = false,
    this.isEnableNotifcations = false,
    this.activeTab = 0,
    
    this.status = FormStatus.initial,
    this.errorMessage,
  });
  @override
  List<Object?> get props =>
      [ 
        language,
        isDarkmode,
        isEnableNotifcations,
        activeTab ,
        
        status,
        errorMessage,
      ];

  SettingsStates copyWith({
    String? language,
    bool? isDarkmode,
    bool? isEnableNotifcations,
    int? activeTab,
    FormStatus? status,
    String? errorMessage,
  }) {
    return SettingsStates(
      language: language?? this.language,
      isDarkmode: isDarkmode?? this.isDarkmode,
      isEnableNotifcations: isEnableNotifcations?? this.isEnableNotifcations,
      activeTab: activeTab?? this.activeTab,
      
      status: status?? this.status,
      errorMessage: errorMessage?? this.errorMessage,
    );
  }
}

class SettingsCubit extends Cubit<SettingsStates> with Manager<SettingsCubit>{
  
  
  final _log = LoggerReprository('SettingsCubit');

  SettingsCubit() :  super(const SettingsStates());

  Future<void> initSettings() async {
    emit(SettingsStates(
      isDarkmode: prefs.isDarkTheme,
      language: prefs.language,
      isEnableNotifcations: prefs.isEnableNotifcations,
    ));
  }
  
  void changeTab(int index) {
    emit(state.copyWith(activeTab: index));
  }
  
  Future<void> settingUpdate(String settingKey,dynamic settingValue) async {
          // language setting
          switch (settingKey) {
            case AppSetts.language:
                await prefs.setlanguage(settingValue);
                emit(state.copyWith(language: settingValue));
            break;
            case AppSetts.theme:
                await prefs.setTheme(settingValue);
                emit(state.copyWith(isDarkmode: settingValue));
            break;
            case AppSetts.enableNotifcations:
                await prefs.setTheme(settingValue);
                emit(state.copyWith(isEnableNotifcations: settingValue));
            break;
            default:
          }
      }

  
}
