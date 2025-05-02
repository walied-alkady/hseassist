
import 'model_base.dart';

class WorkplaceSetting extends ModelBase{
    
  static const collectionString = 'workplaceSettings';

  static const empty = WorkplaceSetting(id: '');

  ///region Getters
  @override
  bool get isEmpty => this == WorkplaceSetting.empty ;
  @override
  bool get isNotEmpty => this != WorkplaceSetting.empty;

  const WorkplaceSetting({
    required this.id,
    this.firstUsePoints=30,
    this.createHazardPoints=1,
    this.createTaskPoints=1,
    this.finishTaskPoints=1,
    this.createIncidentPoints=1,
    this.miniSessionPoints=1,
    this.quizeGameAnswerPoints=1,
    this.quizeGameLevelPoints=3,
    this.appUsageDurationPoints = 1,
    this.targetHazardIdsPerYear = 10,
    this.targetUncompletedTasksPerYear = 10,
    this.targetMiniSessionHrsPerYearPerUser = 10,
  });
  final String id;
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
    @override
  List<Object?> get props => [
    id,
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
  ];
  @override
  Map<String, dynamic> toMap()=> {
          WorkplaceSettingFields.id.name: id,
          WorkplaceSettingFields.firstUsePoints.name: firstUsePoints,
          WorkplaceSettingFields.createHazardPoints.name: createHazardPoints,
          WorkplaceSettingFields.createTaskPoints.name: createTaskPoints,
          WorkplaceSettingFields.finishTaskPoints.name: finishTaskPoints,
          WorkplaceSettingFields.createIncidentPoints.name: createIncidentPoints,
          WorkplaceSettingFields.miniSessionPoints.name: miniSessionPoints,
          WorkplaceSettingFields.quizeGameAnswerPoints.name: quizeGameAnswerPoints,
          WorkplaceSettingFields.quizeGameLevelPoints.name: quizeGameLevelPoints,
          WorkplaceSettingFields.appUsageDurationPoints.name: appUsageDurationPoints,
          WorkplaceSettingFields.targetHazardIdsPerYear.name: targetHazardIdsPerYear,
          WorkplaceSettingFields.targetUncompletedTasksPerYear.name: targetUncompletedTasksPerYear,
          WorkplaceSettingFields.targetMiniSessionHrsPerYearPerUser.name: targetMiniSessionHrsPerYearPerUser,  
    };

  @override
  factory WorkplaceSetting.fromMap(Map<dynamic, dynamic> data) => WorkplaceSetting(
      id: data[WorkplaceSettingFields.id.name] ?? '',
      firstUsePoints: data[WorkplaceSettingFields.firstUsePoints.name] ?? 0,
      createHazardPoints: data[WorkplaceSettingFields.createHazardPoints.name] ?? 0,
      createTaskPoints: data[WorkplaceSettingFields.createTaskPoints.name] ?? 0,
      finishTaskPoints: data[WorkplaceSettingFields.finishTaskPoints.name] ?? 0,
      createIncidentPoints: data[WorkplaceSettingFields.createIncidentPoints.name] ?? 0,
      miniSessionPoints: data[WorkplaceSettingFields.miniSessionPoints.name] ?? 0,
      quizeGameAnswerPoints: data[WorkplaceSettingFields.quizeGameAnswerPoints.name] ?? 0,
      quizeGameLevelPoints: data[WorkplaceSettingFields.quizeGameLevelPoints.name] ?? 0,
      appUsageDurationPoints: data[WorkplaceSettingFields.appUsageDurationPoints.name] ?? 0,
      targetHazardIdsPerYear: data[WorkplaceSettingFields.targetHazardIdsPerYear.name] ?? 0,
      targetUncompletedTasksPerYear: data[WorkplaceSettingFields.targetUncompletedTasksPerYear.name] ?? 0,
      targetMiniSessionHrsPerYearPerUser: data[WorkplaceSettingFields.targetMiniSessionHrsPerYearPerUser.name] ?? 0,
      );
}

enum WorkplaceSettingFields {
  id,
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
}


extension WorkplaceSettingFieldsExtension on WorkplaceSettingFields {
    String get name {
    // Map-based lookup
    return {
      WorkplaceSettingFields.id: 'id',
      WorkplaceSettingFields.firstUsePoints: 'firstUsePoints',
      WorkplaceSettingFields.createHazardPoints: 'createHazardPoints',
      WorkplaceSettingFields.createTaskPoints: 'createTaskPoints',
      WorkplaceSettingFields.finishTaskPoints: 'finishTaskPoints',
      WorkplaceSettingFields.createIncidentPoints: 'createIncidentPoints',
      WorkplaceSettingFields.miniSessionPoints: 'miniSessionPoints',
      WorkplaceSettingFields.quizeGameAnswerPoints: 'quizeGameAnswerPoints',
      WorkplaceSettingFields.quizeGameLevelPoints: 'quizeGameLevelPoints',
      WorkplaceSettingFields.appUsageDurationPoints: 'appUsageDurationPoints',
      WorkplaceSettingFields.targetHazardIdsPerYear: 'targetHazardIdsPerYear',
      WorkplaceSettingFields.targetUncompletedTasksPerYear: 'targetUncompletedTasksPerYear',
      WorkplaceSettingFields.targetMiniSessionHrsPerYearPerUser: 'targetMiniSessionHrsPerYearPerUser',
    }[this]!; 
  }
}