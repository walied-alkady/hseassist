import 'package:hive/hive.dart';

class UserSession extends HiveObject{
  DateTime loginTime;
  DateTime? logoutTime;
  bool isLoggedIn;

  UserSession({required this.loginTime, this.logoutTime,this.isLoggedIn = false});
  
  Duration get duration => logoutTime != null ? logoutTime!.difference(loginTime) : Duration.zero;

  Map<String, dynamic> toMap() {
    return {
      'loginTime': loginTime.toIso8601String(),
      'logoutTime': logoutTime?.toIso8601String(),
    };
  }

  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      loginTime: DateTime.parse(map['loginTime']),
      logoutTime: map['logoutTime'] != null ? DateTime.parse(map['logoutTime']) : null,
    );
  }
}
