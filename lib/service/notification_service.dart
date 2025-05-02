import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../repository/logging_reprository.dart';



class NotificationService {
  
  final _log = LoggerReprository('NotificationService');

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  Future initialize() async {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      _log.i('User granted permission: ${settings.authorizationStatus}');
      
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _log.i('Got a message whilst in the foreground!');
        _log.i('Message data: ${message.data}');

        if (message.notification != null) {
          _log.i('Message also contained a notification: ${message.notification}');
          showNotification(message.notification!.title!, message.notification!.body!);
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _log.i('Message clicked!');
        // Handle the clicked message
      });
      FirebaseMessaging.onBackgroundMessage(backgroundHandler);
      
      // Get the token
      await getToken();
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
        // TODO: If necessary send token to application server.

        // Note: This callback is fired at each app startup and whenever a new
        // token is generated.
      })
      .onError((err) {
        // Error getting token.
      });
  }

  Future<String?> getToken() async {
    String? token = await _fcm.getToken();
    _log.i('Token: $token');
    return token;
  }
    
  Future<void> subscribeToTopic(String topicName) async{
    await FirebaseMessaging.instance.subscribeToTopic(topicName);
  }

  Future<void> unSubscribeToTopic(String topicName) async{
    await FirebaseMessaging.instance.unsubscribeFromTopic(topicName);
  }

  Future<void> backgroundHandler(RemoteMessage message) async {
  _log.i('Handling a background message ${message.messageId}');
  showNotification(message.notification!.title!, message.notification!.body!);
  }

  //to send local notification
  Future<void> showNotification(String title, String body) async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel', // channel id
      'High Importance Notifications', // channel name
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      title,
      body,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }

  //to send push notifcation
  Future<void> sendNoficationToselectedUser({
    required String deviceToken,
    required String title,
    required String type,
    required String recieverId,
    required String senderId,
    required Map<String, dynamic> data,
    required String body}) async {

      final String serverAccessToken = await _getAccessToken();
      //TODO: firebase project id
      String endpointFirebasecloudMessaging ='https://fcm.googleapis.com/v1/projects/you-project-id/messages:send';
      final Map<String, dynamic> message = {
        'message': {
          'token': deviceToken,
          'notification': {
          'title': title,
          'body': body,
          },
          'data': {'type': type},
          'android': {
            // Required for background/terminated app state messages on Android
            'priority': "high",
            'notification': {
            'sound': "default",
            'click_action': "FLUTTER_NOTIFICATION_CLICK",
            'channel_id': "tiktoknotification"
            },
          },
          'apns': {
            'payload': {
              'aps': {
              // Required for background/terminated app state messages on iOS
              'contentAvailable': true,
              'badge': 1,
              'sound': "default"
              },
            },
          },
        }
};
      final http.Response response = await http.post(
        Uri.parse(endpointFirebasecloudMessaging),
        headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessToken'
        },
        body: jsonEncode(message),
      );
      if (response.statusCode == 200) {
      _log.i("Successfully sent:${response.body}");
      } else {
      _log.i("Failed with code:${response.body}");
      }
}

  Future<String> _getAccessToken() async {
    //TODO: Paste your downloaded json file data in serviceAccountJson complete map that you copied in the previous step.
    final serviceAccountJson = {
      'https://fcm.googleapis.com/v1/projects/your-project-id/messages:send'
    };
    List<String> scopes = [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/firebase.database",
    "https://www.googleapis.com/auth/firebase.messaging",
    ];
    http.Client client = await auth.clientViaServiceAccount(
    auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);
    _log.i('get access token using this client');
    auth.AccessCredentials credentials =
    await auth.obtainAccessCredentialsViaServiceAccount(auth.ServiceAccountCredentials.fromJson(serviceAccountJson),scopes,client);
    _log.i('close the client');
    client.close();
    return credentials.accessToken.data;
}

  //test
  // if (widget.userData.id != currentUser.id) {
  // PushNotificationService
  // .sendNoficationToselectedUser(
  // recieverId: widget.userData.id!,
  // senderId: currentUser.id ?? user.id,
  // type: "Like",
  // deviceToken: widget.userData.fcmToken!,
  // title: "${currentUser.userName}",
  // data: {
  // 'videoId': widget.videoData,
  // 'imageUrl': currentUser.profilePic,
  // 'secondUser': currentUser.toJson()
  // },
  // body: "liked your video!");
  // }

}


