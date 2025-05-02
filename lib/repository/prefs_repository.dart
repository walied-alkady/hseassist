import 'package:get_it/get_it.dart';
import 'package:hseassist/repository/logging_reprository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsRepository{
  final log = GetIt.instance<LoggerReprository>()..name = 'PrefsRepository'; 
  final SharedPreferences prefs;
  PrefsRepository({required this.prefs});
  
}