
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import 'model_base.dart';

class HseHazard extends ModelBase{
    
  static const collectionString = 'hseHazards';

  static const empty = HseHazard();
  ///region Getters
  ///region Getters
  @override
  bool get isEmpty => this == HseHazard.empty ;
  @override
  bool get isNotEmpty => this != HseHazard.empty;

  ///endregion

  const HseHazard({
    this.id='',
    this.createdAt,
    this.createdById='',
    this.location='',
    this.locationExtra='',
    this.details='',
    this.hazardType='',
    this.hazardTypeExtra='',
    this.hazardState='',
    this.taskIds = const [],
    this.imgUrl='',
    this.embeding = const []
  });
  final String id;
  final DateTime? createdAt;
  final String createdById; 
  final String location;
  final String locationExtra;
  final String details;
  final String hazardType;
  final String hazardTypeExtra;
  final String hazardState;
  final List<String> taskIds; 
  final String imgUrl;
  final List<double> embeding; 
  ///endregion

  @override
  List<Object?> get props => [
    id,
    createdAt,
    createdById,
    location,
    locationExtra,
    details,
    hazardType,
    hazardTypeExtra,
    hazardState,
    taskIds,
    imgUrl,
    embeding
  ];
  @override
  Map<String, dynamic> toMap()=> {
      HseHazardFields.id.name:id,
      HseHazardFields.createdAt.name:Timestamp.fromDate(createdAt!),
      HseHazardFields.createdById.name:createdById,
      HseHazardFields.location.name: location,
      HseHazardFields.locationExtra.name:locationExtra,
      HseHazardFields.details.name: details,
      HseHazardFields.hazardType.name:hazardType,
      HseHazardFields.hazardTypeExtra.name:hazardTypeExtra,
      HseHazardFields.hazardState.name:hazardState,
      HseHazardFields.taskIds.name:taskIds,
      HseHazardFields.imgUrl.name:imgUrl,
      HseHazardFields.embeding.name:embeding
    };

  @override
  factory HseHazard.fromMap(Map<dynamic, dynamic> data) => HseHazard(
      id: data[HseHazardFields.id.name] ?? '',
      createdAt:(data[HseHazardFields.createdAt.name] as Timestamp).toDate(),
      createdById: data[HseHazardFields.createdById.name] ?? '',
      location: data[HseHazardFields.location.name] ?? '',
      locationExtra : data[HseHazardFields.locationExtra.name] ??'',
      details: data[HseHazardFields.details.name] ?? '',
      hazardType: data[HseHazardFields.hazardType.name] ?? '',
      hazardTypeExtra: data[HseHazardFields.hazardTypeExtra.name] ?? '',
      hazardState: data[HseHazardFields.hazardState.name] ?? '',
      taskIds: List<String>.from(data[HseHazardFields.taskIds.name] ?? []),
      imgUrl: data[HseHazardFields.imgUrl.name] ?? '',
      embeding: List<double>.from(data[HseHazardFields.embeding.name] ?? [])
      );
}

enum HseHazardFields {
  id,
  createdAt,
  createdById,
  location,
  locationExtra,
  details,
  hazardType,
  hazardTypeExtra,
  hazardState,
  taskIds,
  imgUrl,
  embeding
}
extension HseHazardFieldsExtension on HseHazardFields {
  String get name {
    // Map-based lookup
    return {
      HseHazardFields.id: 'id',
      HseHazardFields.createdAt: 'createdAt',
      HseHazardFields.createdById: 'createdById',
      HseHazardFields.location: 'location',
      HseHazardFields.locationExtra: 'locationExtra',
      HseHazardFields.details: 'details',
      HseHazardFields.hazardType: 'hazardType',
      HseHazardFields.hazardTypeExtra: 'hazardTypeExtra',
      HseHazardFields.hazardState: 'hazardState',
      HseHazardFields.taskIds: 'taskIds',
      HseHazardFields.imgUrl: 'imgUrl',
      HseHazardFields.embeding: 'embeding'
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}
