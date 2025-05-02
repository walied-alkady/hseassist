import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hseassist/models/models.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

import '../enums/app_page.dart';
import '../enums/chat_type.dart';
import '../enums/query_operator.dart';
import '../enums/task_status.dart';
import '../pages/chat_page.dart';
import '../repository/admob_repositroy.dart';
import '../repository/logging_reprository.dart';
import '../service/gemini_service.dart';
import 'manager.dart';

class HomePageState extends Equatable{
  final bool loadingData;
  final String loadingString;
  final bool loadingMessage;
  final String  gotAnswerResponse;
  final String  contentMessage;
  final BannerAd? bannerAd;
  final int tasksDueNo;
  final List<HseTask> tasks;
  final int incidentsNo;
  final List<HseIncident> incidents;
  final int hazardsNo;
  final List<HseHazard> hazards;
  final int points;
  final int miniSessionsNo;
  final double pointsRating;
  final double tasksRating;
  final double incidentsRating;
  final double hazardsRating;
  final double overallRating;
  final bool isSpeachAvailable;
  final bool isRecording;
  final bool hazardChartHasData;
  final bool tasksChartHasData;
  final bool hasManagedlocation;
  final WorkplaceLocation? selectedManagedLocation;
  final int bottomNavIndex;
   final List<ChatMessage> messages;          // Single list for all message types
  final bool loadingMessages;
  final String? currentChatId;        // ID of the current chat (can be AI, user, or group)
  final ChatType currentChatType; 
  final List<AuthUser> users;
  final List<ChatGroup> groups;
  final bool loadingUsers;       
  final bool showTutorial;
  final String? logoUrl;
  final DateTime? selectedDay;
  final DateTime? focusedDay; 

  const HomePageState({
    this.loadingData = false,
    this.loadingString = '',
    this.loadingMessage = false,
    this.gotAnswerResponse = 'Type a message',
    this.contentMessage = '',
    this.bannerAd,
    this.tasksDueNo=0,
    this.tasks = const [],
    this.incidentsNo=0,
    this.incidents = const [],
    this.hazards = const [],
    this.hazardsNo=0,
    this.points = 0,
    this.miniSessionsNo = 0,
    this.pointsRating = 0.0,
    this.tasksRating = 0.0,
    this.incidentsRating = 0.0,
    this.hazardsRating = 0.0,
    this.overallRating = 0.0,
    this.isSpeachAvailable = false,
    this.isRecording = false,
    this.hazardChartHasData = false,
    this.tasksChartHasData = false,
    this.hasManagedlocation = false,
    this.selectedManagedLocation,
    this.bottomNavIndex = 0,
    this.messages = const [],
    this.loadingMessages = false,
    this.currentChatId,
    this.currentChatType = ChatType.none,
    this.users = const [],
    this.groups = const [],
    this.loadingUsers = false,
    this.showTutorial = true,
    this.logoUrl,
    this.selectedDay ,
    this.focusedDay ,
  });

  HomePageState copyWith({
    bool? loadingData,
    String? loadingString,
    bool? loadingMessage,
    String? gotAnswerResponse,
    String? contentMessage,
    BannerAd? bannerAd,
    int? tasksDueNo,
    List<HseTask>? tasks,
    int? incidentsNo,
    List<HseIncident>? incidents,
    int? hazardsNo,
    List<HseHazard>? hazards,
    int? points,
    double? pointsRating,
    double? tasksRating,
    double? incidentsRating,
    double? hazardsRating,
    double? overallRating,
    bool? isSpeachAvailable,
    bool? isRecording,
    bool? hazardChartHasData,
    bool? tasksChartHasData,
    bool? hasManagedlocation,
    WorkplaceLocation? selectedManagedLocation,
    int? bottomNavIndex,
    List<ChatMessage>? messages,
    bool? loadingMessages,
    String? currentChatId,
    ChatType? currentChatType,
    List<AuthUser>? users,
    List<ChatGroup>? groups,
    bool? loadingUsers,
    bool? showTutorial,
    String? logoUrl,
    DateTime? selectedDay,
    DateTime? focusedDay,
  }) {
    return HomePageState(
      loadingData: loadingData ?? this.loadingData,
      loadingString: loadingString ?? this.loadingString,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      gotAnswerResponse: gotAnswerResponse ?? this.gotAnswerResponse,
      contentMessage: contentMessage ?? this.contentMessage,
      bannerAd: bannerAd ?? this.bannerAd,
      tasksDueNo: tasksDueNo ?? this.tasksDueNo,
      tasks: tasks ?? this.tasks,
      incidentsNo: incidentsNo ?? this.incidentsNo,
      incidents: incidents ?? this.incidents,
      hazardsNo: hazardsNo ?? this.hazardsNo,
      hazards: hazards ?? this.hazards,
      points: points ?? this.points,
      pointsRating: pointsRating ?? this.pointsRating,
      tasksRating: tasksRating??this.tasksRating,
      incidentsRating: incidentsRating??this.incidentsRating,
      hazardsRating: hazardsRating??this.hazardsRating,
      overallRating: overallRating??this.overallRating,
      isSpeachAvailable: isSpeachAvailable ?? this.isSpeachAvailable,
      isRecording: isRecording ?? this.isRecording,
      hazardChartHasData: hazardChartHasData ?? this.hazardChartHasData,
      tasksChartHasData: tasksChartHasData ?? this.tasksChartHasData,
      hasManagedlocation: hasManagedlocation ?? this.hasManagedlocation,
      selectedManagedLocation: selectedManagedLocation ?? this.selectedManagedLocation,
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
      messages: messages ?? this.messages,
      loadingMessages: loadingMessages ?? this.loadingMessages,
      currentChatId: currentChatId ?? this.currentChatId,  
      currentChatType: currentChatType ?? this.currentChatType,
      users: users ?? this.users,
      groups: groups ?? this.groups,
      loadingUsers: loadingUsers ?? this.loadingUsers,
      showTutorial: showTutorial ?? this.showTutorial,
      logoUrl: logoUrl ?? this.logoUrl,
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      
    );
  }
  
  @override
  List<Object?> get props => [
        loadingData,
        loadingString,
        loadingMessage,
        gotAnswerResponse,
        contentMessage,
        bannerAd,
        tasksDueNo,
        tasks,
        incidentsNo,
        incidents,
        hazards,
        hazardsNo,
        points,
        pointsRating,
        tasksRating,
        incidentsRating,
        hazardsRating,
        overallRating,
        isSpeachAvailable,
        isRecording,
        hazardChartHasData,
        tasksChartHasData,
        hasManagedlocation,
        selectedManagedLocation,
        bottomNavIndex,
        messages,
        loadingMessages,
        currentChatId,
        currentChatType,
        users,
        groups,
        loadingUsers,
        showTutorial,
        logoUrl,
        selectedDay,
        focusedDay,
      ];
}

class HomeCubit extends Cubit<HomePageState> with Manager<HomeCubit>{

  HomeCubit() : super(const HomePageState());
  final _log = LoggerReprository('HomeCubit');
  List<HseTask> tasks = [];
  List<HseIncident> incidents = [];
  List<HseHazard> hazards = [];
  List<HseTask> responsibles = [];
  List<WorkplaceLocation> managedLocation = [];
  List<Map<String, dynamic>>? locationsData;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tasksSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _hazardsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _incidentsSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userWorkplaceSubscription;


  BannerAd? bannerAd;
  AuthUser? currentUser;
  String currentWorkplaceName ='';
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _currentLocaleId = '';
  String _accumulatedText = '';
  
  // Future<void> closeDrawer() async {
  //   _log.i('saving response data to preferences...');  
  //   prefs.updatechatMessages(gemini?.cachChatMessaging);
  //   _log.i('saved...');  
  //   return super.close();
  // }

  Future<void> initForm() async {
    emit(state.copyWith(loadingData: true,loadingString: 'loading...'));
    try{   
        _log.i('getting current user...');
        currentUser = db.currentUser;
        _log.i('got ${currentUser?.email} ...');
        if(currentUser == null) throw Exception('User not found');
        
        _log.i('getting current workplace...');
        final currentWorkplace = await db.findOne<Workplace>(db.currentWorkplaceId!);
        currentWorkplaceName = currentWorkplace?.description??'';
        emit(state.copyWith(logoUrl: currentWorkplace?.logoUrl));  
        _log.i('checking if mobile platform...');
        bool isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
        if(isMobile){
          _log.i('loading mobile configurations...');
          _log.i('Now loading banner...');
          emit(state.copyWith(loadingString: 'loading mobile settings...'));
          bannerAd= BannerAd(
                    adUnitId: AdHelper.bannerAdUnitId,
                    request: const AdRequest(),
                    size: AdSize.banner,
                    listener: BannerAdListener(
                            onAdLoaded: (ad) {
                              _log.i('BannerAd loaded.');
                              emit(state.copyWith(bannerAd: ad as BannerAd));
                            },
                            onAdFailedToLoad: (ad, err) {
                              _log.e('Failed to load a banner ad: ${err.message}');
                              emit(state.copyWith(bannerAd: null)); 
                              ad.dispose();
                              // Set bannerAd to null if loading fails
                            },
                          ),
                        );
          await bannerAd!.load();
          _log.i('Loading banner done...');
          _log.i('Configuring push notification...');
          NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
              alert: true,
              announcement: false,
              badge: true,
              carPlay: false,
              criticalAlert: false,
              provisional: false,
              sound: true,
          );

          if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            _log.i('User granted permission');
            emit(state.copyWith(loadingString: 'User granted permission...'));
          } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
            _log.i('User granted provisional permission');
            emit(state.copyWith(loadingString: 'User granted provisional permission...'));
          } else {
            _log.i('User declined or has not accepted permission');
            emit(state.copyWith(loadingString: 'User declined or has not accepted permission...'));
          }
          _log.i('push notification congifured...');    
          _log.i('configuration for mobile finished...');
        }
        _log.i('check if geminiService is ready...');
        bool isGeminiServiceReady = serviceLocator.isReadySync<GeminiService>();
        if (isGeminiServiceReady) {
          _log.i('gemini is ready , configuring startup data...');
          if(!gemini!.cachChatMessages.any((element) => element.id == 'welcome')){
            emit(state.copyWith(loadingString: 'Loading local chat history...'));
            final welcomeMessage =
              ChatMessage(
                id: 'welcome',
                senderId: const Uuid().v4(),
                chatId: 'ai_chat_id',
                senderName: 'hseAssist', 
                timestamp: DateTime.now(), 
                content: "Welcome to Hse assistant! how may I help you?", 
                isLoading: false
                );
            gemini?.cachChatMessages.add(welcomeMessage);
          }else if (gemini!.cachChatMessages.isNotEmpty && !gemini!.cachChatMessages.any((element) => element.id == 'welcome')) { // If there are messages, but no welcome message, add it
                  final welcomeMessage = ChatMessage(
                senderId: const Uuid().v4(),
                chatId: 'ai_chat_id',
                senderName: 'hseAssist',
                timestamp: DateTime.now(),
                content: "Welcome to Hse assistant! how may I help you?",
                isLoading: false,
                id: 'welcome' // Add a unique ID to the welcome message
              );
          
            gemini?.cachChatMessages.add(welcomeMessage);
          } 
          bool available = await _speech.initialize(
                onStatus: (status) {
                // Handle status changes (e.g., listening, not listening)
                switch (status) {
                  case "listening":
                    emit(state.copyWith(isRecording: true)); // Set recording state to true
                    break;
                  case "notListening":
                    emit(state.copyWith(isRecording: false));// Set recording state to true
                    break;
                  default:
                    emit(state.copyWith(isRecording: false));
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
          emit(state.copyWith(messages: gemini?.cachChatMessages,isSpeachAvailable: available));
          _log.i('done configuring gemini service startup...');
        }
        emit(state.copyWith(loadingString: 'updating lists...'));  
        _log.i('updateing lists...');
        loadLists();
        final currentMonthCounts = await getCurrentMonthCounts();
        _log.i("Current Month counts $currentMonthCounts");
        emit(state.copyWith(loadingString: 'Loading  interface data...'));  
        _tasksSubscription?.cancel(); // Cancel any existing subscription
        _tasksSubscription = db.collectionStream<HseTask>()
        ?.listen((snapshot) {
              tasks = snapshot.docs.map((doc) => HseTask.fromMap(doc.data()))
              .where((task) => task.status == TaskStatus.pending.name)
              .toList();
              emit(state.copyWith(tasks: tasks,tasksDueNo: tasks.length , tasksRating: currentMonthCounts['tasks'] ));
        });
        emit(state.copyWith(tasks: tasks));
        _hazardsSubscription?.cancel(); // Cancel any existing subscription
        _hazardsSubscription = db.collectionStream<HseHazard>()
        ?.listen((snapshot) {
              hazards = snapshot.docs.map((doc) => HseHazard.fromMap(doc.data()))
              .where((hazard) => hazard.createdById == prefs.currentUserId)
              .toList();
              emit(state.copyWith(hazards: hazards,hazardsNo: hazards.length , hazardsRating: currentMonthCounts['hazards'] ));
        });
        _incidentsSubscription?.cancel(); // Cancel any existing subscription
        _incidentsSubscription = db.collectionStream<HseIncident>()
        ?.listen((snapshot) {
              incidents = snapshot.docs.map((doc) => HseIncident.fromMap(doc.data()))
              .where((incident) => incident.createdById == prefs.currentUserId)
              .toList();
              emit(state.copyWith(incidents: incidents,incidentsNo: incidents.length , incidentsRating: currentMonthCounts['incidents']));
        });
        _log.i('lists updated now loading user workplace data...');
        _userWorkplaceSubscription?.cancel(); // Cancel any existing subscription
        if (db.currentUser?.currentWorkplaceDataId != null) {
          final maxPoints = await getHighestPoints();
          _userWorkplaceSubscription = db.documentStream<UserWorkplace>(
            db.currentUser!.currentWorkplaceDataId!,
          )?.listen((snapshot) {
            if (snapshot.exists) {
              final userWorkplaceData = UserWorkplace.fromMap(snapshot.data()!);
              
              emit(state.copyWith(
                points: userWorkplaceData.points,
                pointsRating: maxPoints == 0 ? 0 : (userWorkplaceData.points / maxPoints)*5,
              ));
            } else {
              // Handle the case where the document doesn't exist
              // For example, set points to 0 or show an error message.
              emit(state.copyWith(points: 0));
            }
          });
        }
        _log.i('workplace data loaded...');
        _log.i('calculating overall rating...');
        final overRating = (currentMonthCounts['tasks']??0) * (currentMonthCounts['hazards']??0) * (currentMonthCounts['incidents']??1) /5;
        emit(state.copyWith(loadingString: 'Loading managed locations...',overallRating:overRating));
        _log.i('updatin managed locations...');
        locationsData = await updateManagedLocationData();
        //updating charts
        _log.i('updating charts...');
        if(managedLocation.isNotEmpty || db.isAdmin || db.isCurrentUserMaster){
          emit(state.copyWith(
            loadingString: 'Loading charts...',
            hasManagedlocation: true,
            selectedManagedLocation: db.isAdmin || db.isCurrentUserMaster?null:managedLocation.first)
          );
          await updateHazardChartData();
          await updateIncidentChartData();
          await updateTasksChartData();
        }
        _log.i('Done initializing home page...');

    }on Exception catch (e) {
    _log.e(e.toString());
  }finally{
    emit(state.copyWith(loadingString: 'Done...'));
    Future.delayed(const Duration(seconds: 2), () {  emit( state.copyWith(loadingData: false,loadingString:null)); });
  }
  }
  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    _hazardsSubscription?.cancel();
    bannerAd?.dispose();
    return super.close();
  }
  
  Future<void> loadLists() async{
    await Future.wait<void>([
      db.findAll<HseTask>().then((result) {
        tasks.clear();
        _log.i('got ${result.length} tasks...');  
        emit(state.copyWith(hazardChartHasData:true));
        return tasks.addAll(result);
        }),  
      db.findAll<HseHazard>().then((result) {
        hazards.clear();
        _log.i('got ${result.length} hazards...');  
        emit(state.copyWith(hazardChartHasData:true));
        return hazards.addAll(result);
        }),
      db.findAll<WorkplaceLocation>().then((result) {
        managedLocation.clear();
        _log.i('got ${result.length} manged location...');  
        if(result.isNotEmpty){
          if( db.isAdmin || db.isCurrentUserMaster){
            managedLocation.addAll(result);
          }else{
            for (var val in result) {
              if(val.managerId == prefs.currentUserId){
                managedLocation.add(val);
              }
              //val.managerId == prefs.currentUser?.id?managedLocation.add(val):null;
            }
          }
        }
        return ;
        }),
    ]).catchError(
        (error) {
        _log.e('Error: $error');
        return error;
      }
    );
  }

  void mainTutorialFinished(){
    prefs.setFirstTimeHome(false);
  }
  
  void fabTutorialFinished(){
    prefs.setFirstTimeHomeFab(false);
  }

  void updateChatCach(){
    emit(state.copyWith(messages: gemini?.cachChatMessages));
  }

  Future<void> signOut(BuildContext context) async {
    if(authService.currentAuthUser !=null) {
      await authService.logOut()
    .then((value){
      if(context.mounted){
          context.goNamed(AppPage.login.name);
      }
      })
      .catchError((err) {
            _log.e('Error: $err'); 
          }
      );
    } 
    
  }
  
  void updateContentMessage(String message){
    emit(state.copyWith(contentMessage: message));
  }

  void sendChatMessage(String text) async {
    emit(state.copyWith(contentMessage: text,loadingMessage: true));
    try {
          if (state.contentMessage.isNotEmpty) {
            emit(state.copyWith(messages: gemini?.cachChatMessages,contentMessage: ''));
            _log.i('got response...');
            final senderChat = ChatMessage(
                  id: const Uuid().v4(),
                  chatId: 'ai_bot_${prefs.currentUserId}',  
                  senderId: prefs.currentUserId,
                  senderName: currentUser?.displayName, 
                  content: text,
                  timestamp: DateTime.now(),
                  messageType: 'text',
                  isLoading: false,
              );
            _log.i('saving sender data to cach...');  
            gemini?.cachChatMessages.add(senderChat); 
            emit(
                state.copyWith(
                  messages :gemini?.cachChatMessages,
                  gotAnswerResponse : 'gemini?TypeMessage',
                )
              );
            final recieverChatTemp = ChatMessage(
                    id: const Uuid().v4(), // Or any other ID generation method
                    chatId: 'ai_bot_${prefs.currentUserId}',
                    senderId: 'ai_bot', //  Use your designated AI ID here
                    senderName: 'hseAssist',
                    content: '...',
                    timestamp: DateTime.now(),
                    messageType: 'text',
                    isLoading: true,
                  );
            _log.i('saving temp response data to cach...');  
            gemini?.cachChatMessages.add(recieverChatTemp);  
            emit(
                state.copyWith(
                  messages :gemini?.cachChatMessages,
                )
              ); 
            final res  =await gemini?.getGenerateTextResponse(text);
            gemini?.cachChatMessages.removeWhere((item) => item.id == recieverChatTemp.id);
            _log.i('saving response data to cach...');  
            final recieverChat = ChatMessage(
                    id: const Uuid().v4(),
                    chatId: 'ai_bot_${prefs.currentUserId}',
                    senderId: 'ai_bot',
                    senderName: 'hseAssist',
                    content: res?.text?.trim() ?? '...',
                    timestamp: DateTime.now(),
                    messageType: 'text',
                    isLoading: false,
                  );
            gemini?.cachChatMessages.add(recieverChat);  
            emit(
              state.copyWith(
                messages :gemini?.cachChatMessages,
                gotAnswerResponse : 'gemini?TypeMessage',
              )
            );
          }
    } on Exception catch (e) {
      _log.e(e);
    }finally{
        emit(state.copyWith(
          loadingMessage : false,
          ));
    }

  }

  Future<void> startVoiceRecording() async {
    if (state.isSpeachAvailable && !state.isRecording) { // Check if already listening
    emit(state.copyWith(isRecording: true));
    _accumulatedText = ''; // Reset accumulated text
    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _accumulatedText = result.recognizedWords;
          stopVoiceRecording();
          sendChatMessage(_accumulatedText.trim());
          emit(state.copyWith(isRecording: false));
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
      emit(state.copyWith(isRecording: false));
  }

  void updateSelectedManagedLocation(WorkplaceLocation location){
    emit(state.copyWith(selectedManagedLocation: location));
  }

  void updateBottomNavIndex(int index) async{
    emit(state.copyWith(bottomNavIndex: index));
  }
  
  Future<List<Map<String,dynamic>>?> updateManagedLocationData() async {
    try {
      _log.i('getting location data...');
      //final isAdmin = prefs.currentUser?.currentWorkplaceRole == 'admin';
      List<Map<String,dynamic>> resultList = [];
      int totalHazards = 0;
      int totalIncidents = 0;
      int totalTasks = 0;
    
    for (final location in managedLocation) {
          final locationHazards = await db.findAll<HseHazard>(
            query: HseHazardFields.location.name,
            queryValue: location.description,
            quaryOperator: QueryComparisonOperator.eq
          );
          final locationIncidents = await db.findAll<HseIncident>(
            query: HseIncidentFields.location.name,
            queryValue: location.description,
            quaryOperator: QueryComparisonOperator.eq
          );
          
          int tasksNo = 0;
          for(var hz in locationHazards){
            
            for(var hzTask in hz.taskIds){
              var task =await  db.findOne<HseTask>(hzTask);
              if(task?.status == TaskStatus.pending.name){
                tasksNo++;
              }
            }
          }
          for(var hz in locationIncidents){
            for(var hzTask in hz.immediateActionsIds){
              var task =await  db.findOne<HseTask>(hzTask);
              if(task?.status == TaskStatus.pending.name){
                tasksNo++;
              }
            }
          }
          Map<String,dynamic> locationData = {};
          locationData['location'] = location.description;
          locationData['hazards'] = locationHazards.length;
          locationData['incidents'] = locationIncidents.length;
          locationData['tasks'] = tasksNo;
          _log.i(locationData);
          resultList.add(locationData);
          totalHazards += locationHazards.length;
          totalIncidents += locationIncidents.length;
          totalTasks += tasksNo;
    }
    Map<String, dynamic> totals = {
        'location': 'Total',
        'hazards': totalHazards,
        'incidents': totalIncidents,
        'tasks': totalTasks,
      };
      resultList.add(totals);
    _log.i(resultList);
    return resultList;
    } catch (error) {
      _log.e('Error loading lists: $error');
      // Handle error appropriately, e.g., show an error message to the user.
    }
    return null;
  }

  Future<List<BarChartGroupData>> updateHazardChartData() async {
    _log.i('loading hazard chart data...');
    List<HseHazard> hazards;
    hazards = await db.findAll<HseHazard>(
        query:HseHazardFields.location.name,
        queryValue: state.selectedManagedLocation?.description,
        quaryOperator: QueryComparisonOperator.eq
      );
    if (hazards.isEmpty){
      return [];
    }

    // 1. Group hazards by month
    final Map<int, List<HseHazard>> hazardsByMonth = {};
    for (final hazard in hazards) {
      final month = hazard.createdAt?.month??0; // Assuming createdAt is a String parsable to DateTime
      hazardsByMonth.putIfAbsent(month, () => []).add(hazard);
    }

    // 2. Create BarChartGroupData for each month
    final List<BarChartGroupData> barChartData = hazardsByMonth.entries.map((entry) {
      final month = entry.key;
      final hazardsInMonth = entry.value;
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: hazardsInMonth.length.toDouble(), // Number of hazards in the month
            color: Colors.blue, // Or any color scheme you want
            width: 20, // Adjust width as needed
          ),
        ],
      );
    }).toList();
    _log.i('chart Data count= ${barChartData.length}');

    return barChartData;
  }
  
  Future<List<BarChartGroupData>> updateIncidentChartData() async {
    _log.i('loading Incident chart data...');
    List<HseIncident> incidents;
    incidents = await db.findAll<HseIncident>(
        query:HseHazardFields.location.name,
        queryValue: state.selectedManagedLocation?.description,
        quaryOperator: QueryComparisonOperator.eq
      );
    if (incidents.isEmpty){
      return [];
    }

    // 1. Group hazards by month
    final Map<int, List<HseIncident>> incidentsByMonth = {};
    for (final incident in incidents) {
      final month = incident.createdAt?.month??0; 
      incidentsByMonth.putIfAbsent(month, () => []).add(incident);
    }

    // 2. Create BarChartGroupData for each month
    final List<BarChartGroupData> barChartData = incidentsByMonth.entries.map((entry) {
      final month = entry.key;
      final incidentInMonth = entry.value;
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: incidentInMonth.length.toDouble(), // Number of incidents in the month
            color: Colors.blue, // Or any color scheme you want
            width: 20, // Adjust width as needed
          ),
        ],
      );
    }).toList();
    _log.i('chart Data count= ${barChartData.length}');

    return barChartData;
  }

  Future<List<BarChartGroupData>> updateTasksChartData() async {
    _log.i('loading tasks chart data...');
    List<HseTask> tasks;
    tasks = await db.findAll<HseTask>(
        query: HseHazardFields.location.name,
        queryValue: state.selectedManagedLocation?.description,
        quaryOperator: QueryComparisonOperator.eq
      );
    if (tasks.isEmpty){
      return [];
    }  

    // 1. Group tasks by month
    final Map<int, Map<String, List<HseTask>>> tasksByMonth = {};
    for (final task in tasks) {
      final month = task.dueDate?.month; // Use dueDate for tasks
      tasksByMonth.putIfAbsent(month??0, () => {});

      // Further categorize by status (done/not done)
      tasksByMonth[month]!.putIfAbsent(task.status, () => []).add(task);
    }

    // 2. Create BarChartGroupData for each month
    final List<BarChartGroupData> barChartData = tasksByMonth.entries.map((entry) {
      final month = entry.key;
      final tasksInMonth = entry.value;  // This is now a Map<String, List<HseTask>>

      return BarChartGroupData(
        x: month,
        barRods: [
          // Rod for completed tasks
          BarChartRodData(
            toY: (tasksInMonth[TaskStatus.done.name]?.length ?? 0).toDouble(),
            color: Colors.green,
            width: 20,
          ),
          // Rod for pending/other status tasks (you can customize colors)
          BarChartRodData(
            toY: (tasksInMonth[TaskStatus.pending.name]?.length ?? 0).toDouble(),
            color: Colors.orange, // Customize color as needed
            width: 20,
          ),
        ],
      );
    }).toList();

    _log.i('Tasks chart Data count= ${barChartData.length}');
    return barChartData;
  }

  Future<int> getHighestPoints() async {
    try {
      final workplaceId = db.currentUser?.currentWorkplace;
      final userWorkplaces = await db.findAll<UserWorkplace>(
        query: UserWorkPlaceFields.workpalceId.name, // Assuming you have this field
        queryValue: workplaceId,
        quaryOperator: QueryComparisonOperator.eq
      );

      if (userWorkplaces.isEmpty) {
        _log.i('No users found in this workplace.');
        return 0;
      }

      // Find the maximum points
      int highestPoints = 0;
      for (final userWorkplace in userWorkplaces) {
        if (userWorkplace.points > highestPoints) {
          highestPoints = userWorkplace.points;
        }
      }

      return highestPoints;


    } catch (e) {
      _log.e('Error getting highest points: $e');
      return 0; // Or handle the error as needed
    }
  }

  Future<Map<String, double>> getCurrentMonthCounts() async {
    try {
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year; 

      final userId = prefs.currentUserId; 

      // 1. Get ALL documents first
      final allTasks = await db.findAll<HseTask>();
      final allHazards = await db.findAll<HseHazard>();
      final allIncidents = await db.findAll<HseIncident>();

      // 2. Filter in Dart (client-side)

      // tasks
      final tasks = allTasks.where((task) {
        final dueDate = task.dueDate??DateTime.now();
        return task.responsibleId == userId &&
              (task.status == TaskStatus.created.name || task.status == TaskStatus.pending.name || task.status == TaskStatus.inProgress.name) &&
              dueDate.month == currentMonth &&
              dueDate.year == currentYear;
      }).toList();

      final tasksAll = allTasks.where((task) {
        final dueDate = task.dueDate??DateTime.now();
        return (task.status == TaskStatus.created.name || task.status == TaskStatus.pending.name || task.status == TaskStatus.inProgress.name) &&
              dueDate.month == currentMonth &&
              dueDate.year == currentYear;
      }).toList();
      final allTasksLen = tasksAll.length;
      final tasksLen = tasks.length;
      final double taskPrecent = (tasksLen / allTasksLen);

      // hazards
      final hazards = allHazards.where((hazard) {
        final createdAt = hazard.createdAt;
        return hazard.createdById == userId &&
              createdAt?.month == currentMonth &&
              createdAt?.year == currentYear;
      }).toList();
      final hazardsAll = allHazards.where((hazard) {
        final createdAt = hazard.createdAt;
        return 
              createdAt?.month == currentMonth &&
              createdAt?.year == currentYear;
      }).toList();  
      final hazardPrecent = hazards.length / hazardsAll.length;  
      //incidents
      final incidents = allIncidents.where((incident) {
        final createdAt = incident.createdAt;
        return incident.createdById == userId &&
              createdAt?.month == currentMonth &&
              createdAt?.year == currentYear;
      }).toList();
      final incidentsAll = allIncidents.where((incident) {
        final createdAt = incident.createdAt;
        return 
              createdAt?.month == currentMonth &&
              createdAt?.year == currentYear;
      }).toList();
      final incidentPrecent = incidents.length / incidentsAll.length;  

      return {
        'tasks': taskPrecent.isFinite?taskPrecent*5:0,
        'hazards': hazardPrecent.isFinite?hazardPrecent*5:0,
        'incidents': incidentPrecent.isFinite?incidentPrecent*5:0,
      };

    } catch (e) {
      _log.e('Error getting current month counts: $e');
      return {'tasks': 0, 'hazards': 0, 'incidents': 0}; // Return 0s on error
    }
  }

  void startChatWithUser(BuildContext context, AuthUser user) {
    String chatId = getChatId(prefs.currentUserId, user.id);
    fetchChatHistory(chatId, ChatType.user);
    showModalBottomSheet( // Use showModalBottomSheet
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => ChatPage(
          chatId: chatId,
          chatType: ChatType.user,
          scrollController: controller,
        ),
      ),
    );
  }

  void startChatWithGroup(BuildContext context, ChatGroup group) {  // Add BuildContext
    fetchChatHistory(group.id, ChatType.group);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => ChatPage(
          chatId: group.id,
          chatType: ChatType.group,
          scrollController: controller,
        ),
      ),
    );
  }

  void startAIChat(BuildContext context) {  // Add BuildContext
    fetchChatHistory('ai_chat_id', ChatType.ai);
    showModalBottomSheet(
      context: context,  // Use the BuildContext passed to the function
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet( // Wrap in DraggableScrollableSheet
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => ChatPage(
          chatId: 'ai_chat_id',
          chatType: ChatType.ai,
          scrollController: controller,
        ),
      ),
    );
  }

  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Sort the IDs alphabetically
    return ids.join('_'); // Join the sorted IDs with an underscore
  }

  Future<void> fetchUsersAndGroups() async {
    emit(state.copyWith(loadingUsers: true)); // Start loading

    try {
      final users = await db.findAll<AuthUser>(query: 'id',quaryOperator: QueryComparisonOperator.ne,queryValue:  prefs.currentUserId);
      final groups = await db.findAll<ChatGroup>(); 
      emit(state.copyWith(users: users, groups: groups, loadingUsers: false));
    } catch (e) {
      // ... handle error
      emit(state.copyWith(loadingUsers: false)); // Stop loading in case of error
    }
  }

  Future<void> fetchChatHistory(String chatId, ChatType chatType) async {
    emit(state.copyWith(loadingMessages: true, currentChatId: chatId, currentChatType: chatType));
    try {
      List<ChatMessage> messages;
      if (chatType == ChatType.ai) {
        messages = gemini!.cachChatMessages.cast<ChatMessage>(); 
      } else if (chatType == ChatType.user) {
        messages = await db.findAll<ChatMessage>(query: 'chatId',quaryOperator: QueryComparisonOperator.eq,queryValue:  chatId,orderBy: 'timestamp',isDescending: true);
      } else if (chatType == ChatType.group) {
        messages = await db.findAll<ChatMessage>(query: 'groupId',quaryOperator: QueryComparisonOperator.eq,queryValue:  chatId,orderBy: 'timestamp',isDescending: true);
      } else {
        messages = []; // Handle unknown chat types or initial state
      }
        emit(state.copyWith(messages: messages, loadingMessages: false));

    } catch (e) {
      _log.e('Error fetching chat history: $e');
      emit(state.copyWith(loadingMessages: false));
      // ... (error handling)
    }
  }

  Future<void> sendUserMessage(String chatId, String text) async {
  try {
    final newMessage = ChatMessage(
      id: '',
      chatId: chatId,
      senderId: prefs.currentUserId,
      content: text,
      timestamp: DateTime.now(), // Or FieldValue.serverTimestamp() if using Firestore
      senderName: currentUser?.displayName,

    );
    await db.create<ChatMessage>(newMessage); //'user_messages' assuming its the messages collection name
    // Update the state with the new message
    emit(state.copyWith(messages: List.from(state.messages)..insert(0, newMessage)..sort((a, b) => a.timestamp!.compareTo(b.timestamp!))));
  } catch (e) {
    _log.e('Error sending user message: $e');
  }
}

  Future<void> sendGroupMessage(String groupId, String text) async {
  try {
    final newMessage = ChatMessage( // Assuming you use the same message model for group chats
      id: '',
      chatId: groupId, // Use groupId as chatId for group messages
      senderId: prefs.currentUserId,
      content: text,
      timestamp: DateTime.now(), // Or FieldValue.serverTimestamp() if using Firestore
        senderName: currentUser?.displayName,

    );
    await db.create<ChatMessage>(newMessage); // 'group_messages' your collection name
    // Update the state with the new message
      emit(state.copyWith(messages: List.from(state.messages)..insert(0, newMessage)..sort((a, b) => a.timestamp!.compareTo(b.timestamp!))));
  } catch (e) {
    _log.e('Error sending group message: $e');
    // ... error handling ...
  }
}

  void updateSelectedDay(DateTime newSelectedDay) {
    // 1. Update the selectedDay in the state.
    emit(state.copyWith(selectedDay: newSelectedDay));

    // 2. (Optional) You might want to do other things here, like:
    //    - Fetch tasks for the new selected day.
    //    - Update a list of tasks to display.
    //    - Trigger a UI refresh.
  }

  void updateFocusedDay(DateTime newFocusedDay) {
    // 1. Update the focusedDay in the state.
    emit(state.copyWith(focusedDay: newFocusedDay));

    // 2. (Optional) You might want to do other things here, like:
    //    - Fetch tasks for the new focused month.
    //    - Update the calendar's visible range.
    //    - Trigger a UI refresh.
  }

}
