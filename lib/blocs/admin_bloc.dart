import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../enums/form_status.dart';
import '../models/auth_user.dart';
import '../models/hse_hazard.dart';
import '../models/hse_incident.dart';
import '../models/hse_task.dart';
import '../models/workplace_location.dart';
import '../repository/logging_reprository.dart';
import 'manager.dart';
import '../models/workplace_settings.dart';
import 'package:rxdart/rxdart.dart';
import '../Exceptions/database_exception.dart';

class UpdateAdminData extends Equatable{
  const UpdateAdminData({
    this.tabIndex = 0,
    this.loadingUserData = false,
    this.userSelectionMode = false,
    this.selectedUserIndeces = const {},
    this.firstUsePoints =0,
    this.createHazardPoints = 0,
    this.createTaskPoints = 0,
    this.finishTaskPoints = 0,
    this.createIncidentPoints = 0,
    this.miniSessionPoints = 0,
    this.quizeGameAnswerPoints = 0,
    this.quizeGameLevelPoints = 0,
    this.appUsageDurationPoints = 0,
    this.targetHazardIdsPerYear = 0,
    this.targetUncompletedTasksPerYear = 0,
    this.targetMiniSessionHrsPerYearPerUser = 0,
    this.locations = const [],
    this.modifyLocationIndex=-1,
    this.modifyLocationValue='',
    this.editLocationMessage,

    this.status = FormStatus.initial,
    this.errorMessage,
  });
  final int tabIndex;
  final bool loadingUserData;
  final bool userSelectionMode;
  final Set<int> selectedUserIndeces;
  // admin settings 
  final int firstUsePoints;
  final int createHazardPoints;
  final int createTaskPoints;
  final int finishTaskPoints;
  final int createIncidentPoints;
  final int miniSessionPoints;
  final int quizeGameAnswerPoints;
  final int quizeGameLevelPoints;
  final int appUsageDurationPoints;
  final int targetHazardIdsPerYear;
  final int targetUncompletedTasksPerYear;
  final int targetMiniSessionHrsPerYearPerUser;
  // locations
  final List<WorkplaceLocation> locations;
  final int modifyLocationIndex;
  final String modifyLocationValue;
  final String? editLocationMessage;
  //
  final FormStatus status;
  final String? errorMessage;

  UpdateAdminData copyWith({
    int? tabIndex,
    bool? loadingUserData,
    bool? userSelectionMode,
    Set<int>? selectedUserIndeces,
    
    int? firstUsePoints,
    int? createHazardPoints,
    int? createTaskPoints,
    int? finishTaskPoints,
    int? createIncidentPoints,
    int? miniSessionPoints,
    int? quizeGameAnswerPoints,
    int? quizeGameLevelPoints,
    int? appUsageDurationPoints,
    int? targetHazardIdsPerYear,
    int? targetUncompletedTasksPerYear,
    int? targetMiniSessionHrsPerYearPerUser,
    List<WorkplaceLocation>? locations,
    int? modifyLocationIndex,
    String? modifyLocationValue,
    String? editLocationMessage,

    FormStatus? status,
    String? errorMessage,

  }) {
    return UpdateAdminData(
      tabIndex: tabIndex ?? this.tabIndex,
      loadingUserData: loadingUserData ?? this.loadingUserData,
      userSelectionMode: userSelectionMode ?? this.userSelectionMode,
      selectedUserIndeces: selectedUserIndeces ?? this.selectedUserIndeces,
      firstUsePoints: firstUsePoints?? this.firstUsePoints,
      createHazardPoints: createHazardPoints?? this.createHazardPoints,
      createTaskPoints: createTaskPoints?? this.createTaskPoints,
      finishTaskPoints: finishTaskPoints?? this.finishTaskPoints,
      createIncidentPoints: createIncidentPoints?? this.createIncidentPoints,
      miniSessionPoints: miniSessionPoints?? this.miniSessionPoints,
      quizeGameAnswerPoints: quizeGameAnswerPoints?? this.quizeGameAnswerPoints,
      quizeGameLevelPoints: quizeGameLevelPoints?? this.quizeGameLevelPoints,
      appUsageDurationPoints: appUsageDurationPoints?? this.appUsageDurationPoints,
      targetHazardIdsPerYear: targetHazardIdsPerYear?? this.targetHazardIdsPerYear,
      targetUncompletedTasksPerYear: targetUncompletedTasksPerYear?? this.targetUncompletedTasksPerYear,
      targetMiniSessionHrsPerYearPerUser: targetMiniSessionHrsPerYearPerUser?? this.targetMiniSessionHrsPerYearPerUser,
      
      locations: locations?? this.locations,
      modifyLocationIndex: modifyLocationIndex?? this.modifyLocationIndex,
      modifyLocationValue: modifyLocationValue?? this.modifyLocationValue,
      editLocationMessage: editLocationMessage?? this.editLocationMessage,

      status: status?? this.status,
      errorMessage: errorMessage?? this.errorMessage,
    );
  }
  @override
  List<Object?> get props => [
    tabIndex,
    loadingUserData,
    userSelectionMode,
    selectedUserIndeces,
    firstUsePoints,
        createHazardPoints,
        createTaskPoints,
        finishTaskPoints,
        createIncidentPoints,
        miniSessionPoints,
        quizeGameAnswerPoints,
        quizeGameLevelPoints,
        appUsageDurationPoints,
        targetHazardIdsPerYear,
        targetUncompletedTasksPerYear,
        targetMiniSessionHrsPerYearPerUser,
        locations.length,
        locations,
        modifyLocationIndex,
        modifyLocationValue,
        editLocationMessage,
        status,
        errorMessage,
  ];
}

class AdminCubit1 extends Cubit<UpdateAdminData> with Manager{
  AdminCubit1() : super(const UpdateAdminData()){
    _targetHazardIdsPerYearSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateTargetHazardIdsPerYearInDatabase);  
    _targetUncompletedTasksPerYearSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateTargetUncompletedTasksPerYearInDatabase);  
    _targetMiniSessionHrsPerYearPerUserSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateTargetMiniSessionHrsPerYearInDatabase);  

    _firstUsePointsSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateFirstUsePointsInDatabase);  
    _createHazardPointsSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateCreateHazardPointsInDatabase);  
    _createTaskPointsSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateCreateTaskPointsInDatabase);  
    _finishTaskPointsSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateFinishTaskPointsInDatabase);  
    _createIncidentPointsSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateCreateIncidentPointsInDatabase);  
    _miniSessionPointsPointsSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateMiniSessionPointsInDatabase);  
    _quizeGameAnswerPointsSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateQuizeGameAnswerPointsInDatabase);  
    _quizeGameLevelPointsSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateQuizeGameLevelPointsInDatabase);  
    _appUsageDurationPointsSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_updateAppUsageDurationPointsInDatabase);  
  }

  final _log = LoggerReprository('AdminCubit');
  List<AuthUser> userList =[];
  List<HseHazard> hseHazards = []; // Your actual list of HseHazard objects
  List<HseIncident> hseIncidents = []; // Your list of HseIncident objects
  List<HseTask> hseTasks = []; // Your list of HseTask objects
  WorkplaceSetting? currentWorkplaceSettings;

  //target KPIs
  final BehaviorSubject<int> _targetHazardIdsPerYearSubject = BehaviorSubject<int>();
  final BehaviorSubject<int> _targetUncompletedTasksPerYearSubject = BehaviorSubject<int>();
  final BehaviorSubject<int> _targetMiniSessionHrsPerYearPerUserSubject = BehaviorSubject<int>();
  //point settings
  final BehaviorSubject<int> _firstUsePointsSubject = BehaviorSubject<int>();
  final BehaviorSubject<int> _createHazardPointsSubject = BehaviorSubject<int>();
  final BehaviorSubject<int> _createTaskPointsSubject = BehaviorSubject<int>();
  final BehaviorSubject<int> _finishTaskPointsSubject = BehaviorSubject<int>();
  final BehaviorSubject<int> _createIncidentPointsSubject = BehaviorSubject<int>();
  final BehaviorSubject<int> _miniSessionPointsPointsSubject = BehaviorSubject<int>();
  final BehaviorSubject<int> _quizeGameAnswerPointsSubject = BehaviorSubject<int>();
  final BehaviorSubject<int> _quizeGameLevelPointsSubject = BehaviorSubject<int>();
  final BehaviorSubject<int> _appUsageDurationPointsSubject = BehaviorSubject<int>();


  Future<void> initData() async {
    try{
      _log.i('loading settings...');
      emit(state.copyWith(loadingUserData: true));
      currentWorkplaceSettings = await db.findAll<WorkplaceSetting>().then(
        (list) => list.firstOrNull
      );
      _log.i('settings loaded,updateing lists...');
      await loadLists();
      _log.i('lists updated...');
      emit(state.copyWith(
      firstUsePoints: currentWorkplaceSettings?.firstUsePoints??0,
      createHazardPoints: currentWorkplaceSettings?.createHazardPoints??0,
      createTaskPoints: currentWorkplaceSettings?.createTaskPoints??0,
      finishTaskPoints: currentWorkplaceSettings?.finishTaskPoints??0,
      createIncidentPoints : currentWorkplaceSettings?.createIncidentPoints??0,
      miniSessionPoints: currentWorkplaceSettings?.miniSessionPoints??0,
      quizeGameAnswerPoints: currentWorkplaceSettings?.quizeGameAnswerPoints??0,
      quizeGameLevelPoints: currentWorkplaceSettings?.quizeGameLevelPoints??0,
      appUsageDurationPoints: currentWorkplaceSettings?.appUsageDurationPoints??0,
      targetHazardIdsPerYear: currentWorkplaceSettings?.targetHazardIdsPerYear??0,
      targetUncompletedTasksPerYear: currentWorkplaceSettings?.targetUncompletedTasksPerYear??0,
      targetMiniSessionHrsPerYearPerUser: currentWorkplaceSettings?.targetMiniSessionHrsPerYearPerUser??0,
    ));
      _log.i('Done...');
    }catch(e){
      _log.i('Loading error...');
    }finally{
      emit(state.copyWith(loadingUserData: false));
    }
  }

  Future<void> loadLists() async{
    await Future.wait<void>([
      db.findAll<AuthUser>().then((result) {
        userList.clear();
        _log.i('got ${result.length} users...');  
        return userList.addAll(result);
        }),
      db.findAll<HseHazard>().then((result) {
        hseHazards.clear();
        _log.i('got ${result.length} hseHazards...');  
        return hseHazards.addAll(result);
        }),
      db.findAll<HseIncident>().then((result) {
        hseIncidents.clear();
        _log.i('got ${result.length} hseIncidents...');  
        return hseIncidents.addAll(result);
        }),
      db.findAll<HseTask>().then((result) {
        hseTasks.clear();
        _log.i('got ${result.length} hseTasks...');  
        return hseTasks.addAll(result);
        })
    ]).catchError(
        (error) {
        _log.e('Error: $error');
        return error;
      }
    );
  }

  void updateTabIndex(int newIndex){
    emit(state.copyWith(tabIndex: newIndex));
  }
  
  Future<void> userItemTapped(int tappedIndex) async {
    final updatedIndices = Set<int>.from(state.selectedUserIndeces);
    if (updatedIndices.contains(tappedIndex)) {
      updatedIndices.remove(tappedIndex);
    } else {
      updatedIndices.add(tappedIndex);
    }
    emit(state.copyWith(selectedUserIndeces: updatedIndices));
  }

  void userItemLongTapped() {
        if(state.selectedUserIndeces.isNotEmpty) {
          emit(state.copyWith(
            userSelectionMode: true
          ));
        }else{
          emit(state.copyWith(
            userSelectionMode: false
          ));
        }
  }

  List<ChartData> getUserPointsData() {
    // 1. Hazard Reports Submitted:
    Map<String, int> userHazardPoints = {};
    for (var hazard in hseHazards) {
      userHazardPoints[hazard.createdById] = (userHazardPoints[hazard.createdById] ?? 0) + 1;
    }

    // 2. Incidents Reported:
    Map<String, int> userIncidentPoints = {};
    for (var incident in hseIncidents) { 
      userIncidentPoints[incident.createdById] = (userIncidentPoints[incident.createdById] ?? 0) + 1;
    }

    // 3. Tasks Completed:
    Map<String, int> userTaskPoints = {};
    for (var task in hseTasks) {
      if (task.status == 'completed') { // Check if the task is completed
        userTaskPoints[task.responsibleId] = (userTaskPoints[task.responsibleId] ?? 0) + 2;
      }
    }

    // 4. Combine Points and Get User Names:
    List<ChartData> userPointsData = [];
    for (var user in userList) {
      int totalPoints = (userHazardPoints[user.id] ?? 0) +
          (userIncidentPoints[user.id] ?? 0) +
          (userTaskPoints[user.id] ?? 0);

      if (totalPoints > 0) {
        userPointsData.add(ChartData("${user.firstName} ${user.lastName}", totalPoints));
      }
    }

    return userPointsData;
  }
  
  Future<void> updateFirstUsePoints(int newPoints) async {
   emit(state.copyWith(firstUsePoints: newPoints)); // Update UI state *immediately*
    _firstUsePointsSubject.add(newPoints);
  }

  Future<void> _updateFirstUsePointsInDatabase(int firstUsePoints) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.firstUsePoints.name: firstUsePoints},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          firstUsePoints: currentWorkplaceSettings?.firstUsePoints ?? 0, // Revert to the original value from the database
          status: FormStatus.failure));
    }
  }

  Future<void> updateCreateHazardPoints(int newPoints) async {
   emit(state.copyWith(createHazardPoints: newPoints)); // Update UI state *immediately*
    _createHazardPointsSubject.add(newPoints);
  }
  
  Future<void> _updateCreateHazardPointsInDatabase(int newPoints) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.createHazardPoints.name: newPoints},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          createHazardPoints: currentWorkplaceSettings?.createHazardPoints ?? 0, // Revert to the original value from the database
          status: FormStatus.failure));
    }
  }

  Future<void> updateCreateTaskPoints(int newPoints) async {
    emit(state.copyWith(createTaskPoints: newPoints)); 
    _createTaskPointsSubject.add(newPoints);
  }
  
  Future<void> _updateCreateTaskPointsInDatabase(int newPoints) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.createTaskPoints.name: newPoints},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          createTaskPoints: currentWorkplaceSettings?.createTaskPoints ?? 0, 
          status: FormStatus.failure));
    }
  }

  Future<void> updateFinishTaskPoints(int newPoints) async {
    emit(state.copyWith(finishTaskPoints: newPoints)); 
    _finishTaskPointsSubject.add(newPoints);
  }
  
  Future<void> _updateFinishTaskPointsInDatabase(int newPoints) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.finishTaskPoints.name: newPoints},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          finishTaskPoints: currentWorkplaceSettings?.finishTaskPoints ?? 0, 
          status: FormStatus.failure));
    }
  }

  Future<void> updateCreateIncidentPoints(int newPoints) async {
    emit(state.copyWith(createIncidentPoints: newPoints)); 
    _createIncidentPointsSubject.add(newPoints);
  }
  
  Future<void> _updateCreateIncidentPointsInDatabase(int newPoints) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.createIncidentPoints.name: newPoints},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          createIncidentPoints: currentWorkplaceSettings?.createIncidentPoints ?? 0, 
          status: FormStatus.failure));
    }
  }

  Future<void> updateMiniSessionPoints(int newPoints) async {
    emit(state.copyWith(miniSessionPoints: newPoints)); 
    _miniSessionPointsPointsSubject.add(newPoints);
  }
  
  Future<void> _updateMiniSessionPointsInDatabase(int newPoints) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.miniSessionPoints.name: newPoints},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          miniSessionPoints: currentWorkplaceSettings?.miniSessionPoints ?? 0, 
          status: FormStatus.failure));
    }
  }
  
  Future<void> updateQuizeGameAnswerPoints(int newPoints) async {
    emit(state.copyWith(quizeGameAnswerPoints: newPoints)); 
    _quizeGameAnswerPointsSubject.add(newPoints);
  }
  
  Future<void> _updateQuizeGameAnswerPointsInDatabase(int newPoints) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.quizeGameAnswerPoints.name: newPoints},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          quizeGameAnswerPoints: currentWorkplaceSettings?.quizeGameAnswerPoints ?? 0, 
          status: FormStatus.failure));
    }
  }
  
  Future<void> updateQuizeGameLevelPoints(int newPoints) async {
    emit(state.copyWith(quizeGameLevelPoints: newPoints)); 
    _quizeGameLevelPointsSubject.add(newPoints);
  }
  
  Future<void> _updateQuizeGameLevelPointsInDatabase(int newPoints) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.quizeGameLevelPoints.name: newPoints},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          quizeGameLevelPoints: currentWorkplaceSettings?.quizeGameLevelPoints ?? 0, 
          status: FormStatus.failure));
    }
  }
  
  Future<void> updateAppUsageDurationPoints(int newPoints) async {
    emit(state.copyWith(appUsageDurationPoints: newPoints)); 
    _appUsageDurationPointsSubject.add(newPoints);
  }
  
  Future<void> _updateAppUsageDurationPointsInDatabase(int newPoints) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.appUsageDurationPoints.name: newPoints},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          appUsageDurationPoints: currentWorkplaceSettings?.appUsageDurationPoints ?? 0, 
          status: FormStatus.failure));
    }
  }
  
  Future<void> updateTargetHazardIdsPerYear(int val) async {
    emit(state.copyWith(targetHazardIdsPerYear: val)); 
    _targetHazardIdsPerYearSubject.add(val);
  }
  
  Future<void> _updateTargetHazardIdsPerYearInDatabase(int val) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.targetHazardIdsPerYear.name: val},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          targetHazardIdsPerYear: currentWorkplaceSettings?.targetHazardIdsPerYear ?? 0, 
          status: FormStatus.failure));
    }
  }
  
  Future<void> updateTargetUncompletedTasksPerYear(int val) async {
    emit(state.copyWith(targetUncompletedTasksPerYear: val)); 
    _targetUncompletedTasksPerYearSubject.add(val);
  }
  
  Future<void> _updateTargetUncompletedTasksPerYearInDatabase(int val) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.targetUncompletedTasksPerYear.name: val},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          targetUncompletedTasksPerYear: currentWorkplaceSettings?.targetUncompletedTasksPerYear ?? 0, 
          status: FormStatus.failure));
    }
  }
  
  Future<void> updateTargetMiniSessionHrsPerYearPerUser(int val) async {
    emit(state.copyWith(targetMiniSessionHrsPerYearPerUser: val)); 
    _targetMiniSessionHrsPerYearPerUserSubject.add(val);
  }
  
  Future<void> _updateTargetMiniSessionHrsPerYearInDatabase(int val) async {
    try {
      await db.updateOne<WorkplaceSetting>(
        currentWorkplaceSettings!.id,
        {WorkplaceSettingFields.targetMiniSessionHrsPerYearPerUser.name: val},
      );
      // No need to update state here, as the UI is already updated.
      // Only handle errors.
    } on DatabaseFailure catch (e) {
      _log.e('Error updating setting: ${e.message}');
      // Optionally revert the UI to the previous value if the DB update fails.
      emit(state.copyWith(
          errorMessage: e.message,
          targetMiniSessionHrsPerYearPerUser: currentWorkplaceSettings?.targetMiniSessionHrsPerYearPerUser ?? 0, 
          status: FormStatus.failure));
    }
  }
  
}

class AdminCubit extends Cubit<UpdateAdminData> with Manager {
  AdminCubit() : super(const UpdateAdminData()) {
    // Setup debounced listeners using the settingsMap.
    settingsMap.forEach((key, value) {
      value.subject.debounceTime(const Duration(milliseconds: 500))
          .listen((newValue) => _updateSettingInDatabase(key, newValue));
    });
  }

  final _log = LoggerReprository('AdminCubit');
  List<AuthUser> userList = [];
  List<HseHazard> hseHazards = [];
  List<HseIncident> hseIncidents = [];
  List<HseTask> hseTasks = [];
  WorkplaceSetting? currentWorkplaceSettings;
  final List<WorkplaceLocation> _locations = [];
  
  final Map<String, SettingData> settingsMap = {
    'firstUsePoints': SettingData(
        BehaviorSubject<int>(), 'firstUsePoints', WorkplaceSettingFields.firstUsePoints),
    'createHazardPoints': SettingData(BehaviorSubject<int>(), 'createHazardPoints',
        WorkplaceSettingFields.createHazardPoints),
    'createTaskPoints': SettingData(
        BehaviorSubject<int>(), 'createTaskPoints', WorkplaceSettingFields.createTaskPoints),
    'finishTaskPoints': SettingData(BehaviorSubject<int>(), 'finishTaskPoints',
        WorkplaceSettingFields.finishTaskPoints),
    'createIncidentPoints': SettingData(BehaviorSubject<int>(), 'createIncidentPoints',
        WorkplaceSettingFields.createIncidentPoints),
    'miniSessionPoints': SettingData(BehaviorSubject<int>(), 'miniSessionPoints',
        WorkplaceSettingFields.miniSessionPoints),
    'quizeGameAnswerPoints': SettingData(BehaviorSubject<int>(), 'quizeGameAnswerPoints',
        WorkplaceSettingFields.quizeGameAnswerPoints),
    'quizeGameLevelPoints': SettingData(BehaviorSubject<int>(), 'quizeGameLevelPoints',
        WorkplaceSettingFields.quizeGameLevelPoints),
    'appUsageDurationPoints': SettingData(BehaviorSubject<int>(), 'appUsageDurationPoints',
        WorkplaceSettingFields.appUsageDurationPoints),
    'targetHazardIdsPerYear': SettingData(BehaviorSubject<int>(), 'targetHazardIdsPerYear',
    WorkplaceSettingFields.targetHazardIdsPerYear),
    'targetUncompletedTasksPerYear': SettingData(
        BehaviorSubject<int>(),
        'targetUncompletedTasksPerYear',
        WorkplaceSettingFields.targetUncompletedTasksPerYear),
    'targetMiniSessionHrsPerYearPerUser': SettingData(
        BehaviorSubject<int>(),
        'targetMiniSessionHrsPerYearPerUser',
        WorkplaceSettingFields.targetMiniSessionHrsPerYearPerUser),
  };

  Future<void> initData() async {
    try {
      _log.i('loading settings...');
      emit(state.copyWith(loadingUserData: true));
      currentWorkplaceSettings = await db.findAll<WorkplaceSetting>().then((list) => list.firstOrNull);
      _log.i('settings loaded,updateing lists...');
      await loadLists();
      _log.i('lists updated...');
        final Map<String, int> initialSettings = {
          'firstUsePoints': currentWorkplaceSettings?.firstUsePoints ?? 0,
          'createHazardPoints': currentWorkplaceSettings?.createHazardPoints ?? 0,
          'createTaskPoints': currentWorkplaceSettings?.createTaskPoints ?? 0,
          'finishTaskPoints': currentWorkplaceSettings?.finishTaskPoints ?? 0,
          'createIncidentPoints': currentWorkplaceSettings?.createIncidentPoints ?? 0,
          'miniSessionPoints': currentWorkplaceSettings?.miniSessionPoints ?? 0,
          'quizeGameAnswerPoints': currentWorkplaceSettings?.quizeGameAnswerPoints ?? 0,
          'quizeGameLevelPoints': currentWorkplaceSettings?.quizeGameLevelPoints ?? 0,
          'appUsageDurationPoints': currentWorkplaceSettings?.appUsageDurationPoints ?? 0,
          'targetHazardIdsPerYear': currentWorkplaceSettings?.targetHazardIdsPerYear ?? 0,
          'targetUncompletedTasksPerYear': currentWorkplaceSettings?.targetUncompletedTasksPerYear ?? 0,
          'targetMiniSessionHrsPerYearPerUser':
              currentWorkplaceSettings?.targetMiniSessionHrsPerYearPerUser ?? 0,
        };
        emit(state.copyWith(
            firstUsePoints: initialSettings['firstUsePoints'],
            createHazardPoints: initialSettings['createHazardPoints'],
            createTaskPoints: initialSettings['createTaskPoints'],
            finishTaskPoints: initialSettings['finishTaskPoints'],
            createIncidentPoints: initialSettings['createIncidentPoints'],
            miniSessionPoints: initialSettings['miniSessionPoints'],
            quizeGameAnswerPoints: initialSettings['quizeGameAnswerPoints'],
            quizeGameLevelPoints: initialSettings['quizeGameLevelPoints'],
            appUsageDurationPoints: initialSettings['appUsageDurationPoints'],
            targetHazardIdsPerYear: initialSettings['targetHazardIdsPerYear'],
            targetUncompletedTasksPerYear: initialSettings['targetUncompletedTasksPerYear'],
            targetMiniSessionHrsPerYearPerUser:initialSettings['targetMiniSessionHrsPerYearPerUser'],
            locations: List.from(_locations)
            ));

      _log.i('Done...');
    } catch (e) {
      _log.i('Loading error...');
    } finally {
      emit(state.copyWith(loadingUserData: false));
    }
  }

  Future<void> loadLists() async {
    await Future.wait<void>([
      db.findAll<AuthUser>().then((result) {
        userList.clear();
        _log.i('got ${result.length} users...');
        return userList.addAll(result);
      }),
      db.findAll<HseHazard>().then((result) {
        hseHazards.clear();
        _log.i('got ${result.length} hseHazards...');
        return hseHazards.addAll(result);
      }),
      db.findAll<HseIncident>().then((result) {
        hseIncidents.clear();
        _log.i('got ${result.length} hseIncidents...');
        return hseIncidents.addAll(result);
      }),
      db.findAll<HseTask>().then((result) {
        hseTasks.clear();
        _log.i('got ${result.length} hseTasks...');
        return hseTasks.addAll(result);
      }),
      db.findAll<WorkplaceLocation>().then((result) {
        _locations.clear();
        _log.i('got ${result.length} locations data...');  
        return _locations.addAll(result);
        })
    ]).catchError((error) {
      _log.e('Error: $error');
      return error;
    });
  }

  void updateTabIndex(int newIndex) {
    emit(state.copyWith(tabIndex: newIndex));
  }

  Future<void> userItemTapped(int tappedIndex) async {
    final updatedIndices = Set<int>.from(state.selectedUserIndeces);
    if (updatedIndices.contains(tappedIndex)) {
      updatedIndices.remove(tappedIndex);
    } else {
      updatedIndices.add(tappedIndex);
    }
    emit(state.copyWith(selectedUserIndeces: updatedIndices));
  }

  void userItemLongTapped() {
    if (state.selectedUserIndeces.isNotEmpty) {
      emit(state.copyWith(userSelectionMode: true));
    } else {
      emit(state.copyWith(userSelectionMode: false));
    }
  }

  List<ChartData> getUserPointsData() {
    Map<String, int> userHazardPoints = {};
    for (var hazard in hseHazards) {
      userHazardPoints[hazard.createdById] = (userHazardPoints[hazard.createdById] ?? 0) + 1;
    }

    Map<String, int> userIncidentPoints = {};
    for (var incident in hseIncidents) {
      userIncidentPoints[incident.createdById] = (userIncidentPoints[incident.createdById] ?? 0) + 1;
    }

    Map<String, int> userTaskPoints = {};
    for (var task in hseTasks) {
      if (task.status == 'completed') {
        userTaskPoints[task.responsibleId] = (userTaskPoints[task.responsibleId] ?? 0) + 2;
      }
    }

    List<ChartData> userPointsData = [];
    for (var user in userList) {
      int totalPoints = (userHazardPoints[user.id] ?? 0) +
          (userIncidentPoints[user.id] ?? 0) +
          (userTaskPoints[user.id] ?? 0);

      if (totalPoints > 0) {
        userPointsData.add(ChartData("${user.firstName} ${user.lastName}", totalPoints));
      }
    }

    return userPointsData;
  }
  // locations
    Future<void> addLocation(String addLocationText) async {
    emit(state.copyWith(status: FormStatus.inProgress));
    final alreadyExists =_locations.any((element) => element.description.trim() == addLocationText);

    if(addLocationText==''){
      emit(state.copyWith(editLocationMessage: 'errorMessages.empty'.tr()));
     // log.i("state.message: ${state.errorMessage}");
      return;
    }else if(alreadyExists){
      emit(state.copyWith(editLocationMessage: 'errorMessages.alreadyExists'.tr()));
      //log.i("state.message: ${state.errorMessage}");
      return;
    }
    else{      
      final newLocation = WorkplaceLocation(id:'' ,description: addLocationText); 
      try {
        
        final newLocationId = await db.create<WorkplaceLocation>(newLocation);
        _locations.add(WorkplaceLocation(id:newLocationId! ,description:  addLocationText));
        emit(state.copyWith(locations: List.from(_locations))); // Or a success state
      } catch (e) {
        emit(state.copyWith(status: FormStatus.failure, errorMessage: 'Error adding location: $e'));
      }finally{
        emit(state.copyWith(status: FormStatus.initial,errorMessage: null));
      }
    }
  }

  Future<void> removeLocation(int index)async{
    emit(state.copyWith(status: FormStatus.inProgress));
    try{
      if(_locations[index].description == 'all'){
        throw Exception('cannot remove ''all'' location');
      }
      await db.deleteOne<WorkplaceLocation>(_locations[index].id);
      _locations.removeAt(index);
      emit(state.copyWith(locations: List.from(_locations)));
    }catch (e) {
        emit(state.copyWith(status: FormStatus.failure,errorMessage: e.toString()));
    }finally{
      emit(state.copyWith(status: FormStatus.initial,errorMessage: null));
    }
  }

  Future<void> renameLocation(int index,String value) async {
    // final w = WorkplaceLocation(description: value);
    // _locations[index] = w; 
    //emit(state.copyWith(locations: List.from(_locations)));
    try{
    if(_locations[index].description == 'all'){
        throw Exception('cannot rename ''all'' location');
    }
    emit(state.copyWith(modifyLocationIndex: index,modifyLocationValue: value));
    await renameLocationSubmit();
    }catch (e) {
        emit(state.copyWith(status: FormStatus.failure,errorMessage: e.toString()));
    }finally{
      emit(state.copyWith(status: FormStatus.initial,errorMessage: null));
    }
  }
  
  Future<void> renameLocationSubmit() async{
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      final w = WorkplaceLocation(id:_locations[state.modifyLocationIndex].id,description: state.modifyLocationValue);
      await db.updateOne<WorkplaceLocation>( _locations[state.modifyLocationIndex].id, {WorkplaceLocationFields.description.name: state.modifyLocationValue})  ;
      _locations[state.modifyLocationIndex] = w; 
      emit(state.copyWith(locations: List.from(_locations)));
    } on Exception catch (e) {
        emit(state.copyWith(status: FormStatus.failure, errorMessage: 'Error renaming location: $e'));

    }finally{
      emit(state.copyWith(status: FormStatus.initial,errorMessage: null));
    }
  }
  
  // Generic update function.
  Future<void> updateSetting(String settingKey, int newValue) async {
    if (settingsMap.containsKey(settingKey)) {
      final settingData = settingsMap[settingKey]!;
      // Update the UI state immediately.
    emit(
        state.copyWith(
        // Use a conditional update based on the stateKey
        firstUsePoints: settingData.stateKey == 'firstUsePoints' ? newValue : null,
        createHazardPoints: settingData.stateKey == 'createHazardPoints' ? newValue : null,
        createTaskPoints: settingData.stateKey == 'createTaskPoints' ? newValue : null,
        finishTaskPoints: settingData.stateKey == 'finishTaskPoints' ? newValue : null,
        createIncidentPoints: settingData.stateKey == 'createIncidentPoints' ? newValue : null,
        miniSessionPoints: settingData.stateKey == 'miniSessionPoints' ? newValue : null,
        quizeGameAnswerPoints: settingData.stateKey == 'quizeGameAnswerPoints' ? newValue : null,
        quizeGameLevelPoints: settingData.stateKey == 'quizeGameLevelPoints' ? newValue : null,
        appUsageDurationPoints: settingData.stateKey == 'appUsageDurationPoints' ? newValue : null,
        targetHazardIdsPerYear: settingData.stateKey == 'targetHazardIdsPerYear' ? newValue : null,
        targetUncompletedTasksPerYear: settingData.stateKey == 'targetUncompletedTasksPerYear' ? newValue : null,
        targetMiniSessionHrsPerYearPerUser: settingData.stateKey == 'targetMiniSessionHrsPerYearPerUser' ? newValue : null,
        )
      );

      // Add the new value to the BehaviorSubject
      settingData.subject.add(newValue);
    }
  }

  Future<void> _updateSettingInDatabase(String settingKey, int newValue) async {
    if (settingsMap.containsKey(settingKey)) {
      final settingData = settingsMap[settingKey]!;
      try {
        await db.updateOne<WorkplaceSetting>(
          currentWorkplaceSettings!.id,
          {settingData.dbField.name: newValue},
        );
      } on DatabaseFailure catch (e) {
        _log.e('Error updating setting $settingKey: ${e.message}');
        // Revert to original value on failure
          final originalValue = currentWorkplaceSettings?.toMap()[settingData.dbField.name] as int?;

        emit(
        state.copyWith(
        // Use a conditional update based on the stateKey
        firstUsePoints: settingData.stateKey == 'firstUsePoints' ? originalValue : null,
        createHazardPoints: settingData.stateKey == 'createHazardPoints' ? originalValue : null,
        createTaskPoints: settingData.stateKey == 'createTaskPoints' ? originalValue : null,
        finishTaskPoints: settingData.stateKey == 'finishTaskPoints' ? originalValue : null,
        createIncidentPoints: settingData.stateKey == 'createIncidentPoints' ? originalValue : null,
        miniSessionPoints: settingData.stateKey == 'miniSessionPoints' ? originalValue : null,
        quizeGameAnswerPoints: settingData.stateKey == 'quizeGameAnswerPoints' ? originalValue : null,
        quizeGameLevelPoints: settingData.stateKey == 'quizeGameLevelPoints' ? originalValue : null,
        appUsageDurationPoints: settingData.stateKey == 'appUsageDurationPoints' ? originalValue : null,
        targetHazardIdsPerYear: settingData.stateKey == 'targetHazardIdsPerYear' ? originalValue : null,
        targetUncompletedTasksPerYear: settingData.stateKey == 'targetUncompletedTasksPerYear' ? originalValue : null,
        targetMiniSessionHrsPerYearPerUser: settingData.stateKey == 'targetMiniSessionHrsPerYearPerUser' ? originalValue : null,
        )
      );
      }
    }
  }
}

// Define a custom data structure for the setting.
class SettingData {
    final BehaviorSubject<int> subject;
    final String stateKey;
    final WorkplaceSettingFields dbField;

    SettingData(this.subject, this.stateKey, this.dbField);
  }

class ChartData {
  final String x;
  final int y;

  ChartData(this.x, this.y);
}