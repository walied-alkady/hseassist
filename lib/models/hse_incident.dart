
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import 'model_base.dart';

class HseIncident extends ModelBase{
    
  static const collectionString = 'hseIncidents';

  static const empty = HseIncident();

  ///region Getters
  @override
  bool get isEmpty => this == HseIncident.empty ;
  @override
  bool get isNotEmpty => this != HseIncident.empty;
  ///endregion

  const HseIncident({
    this.id='',
    this.createdAt,
    this.createdById='',
    this.location='',
    this.locationExtra='',
    this.details='',
    this.incidentType='',
    this.incidentTypeExtra='',
    this.damageOrInjury='',
    this.immediateActionsIds=const [],
    this.preventionReccomendations='',
    this.imgUrl='',
    
  });
  final String id;
  final DateTime? createdAt;
  final String createdById;
  final String location;
  final String locationExtra;
  final String details;
  final String incidentType;
  final String incidentTypeExtra;
  final String damageOrInjury;
  final String preventionReccomendations;
  final List<String> immediateActionsIds; 
  final String imgUrl;
  ///endregion

  @override
  List<Object?> get props => [
    id,
    createdAt,
    createdById,
    location,
    locationExtra,
    details,
    incidentType,
    incidentTypeExtra,
    damageOrInjury,
    immediateActionsIds,
    preventionReccomendations,
    imgUrl,
  ];
  @override
  Map<String, dynamic> toMap()=> {
      HseIncidentFields.id.name:id,
      HseIncidentFields.createdAt.name:Timestamp.fromDate(createdAt!),
      HseIncidentFields.createdById.name:createdById,
      HseIncidentFields.location.name: location,
      HseIncidentFields.locationExtra.name:locationExtra,
      HseIncidentFields.details.name: details,
      HseIncidentFields.incidentType.name:incidentType,
      HseIncidentFields.incidentTypeExtra.name:incidentTypeExtra,
      HseIncidentFields.damageOrInjury.name:damageOrInjury,
      HseIncidentFields.immediateActionsIds.name:immediateActionsIds,
      HseIncidentFields.preventionReccomendations.name:preventionReccomendations,
      HseIncidentFields.imgUrl.name:imgUrl,
      
    };

  @override
  factory HseIncident.fromMap(Map<dynamic, dynamic> data) => HseIncident(
      id: data[HseIncidentFields.id.name] ?? '',
      createdAt:(data[HseIncidentFields.createdAt.name] as Timestamp).toDate(),
      createdById: data[HseIncidentFields.createdById.name] ?? '',
      location: data[HseIncidentFields.location.name] ?? '',
      locationExtra : data[HseIncidentFields.locationExtra.name] ??'',
      details: data[HseIncidentFields.details.name] ?? '',
      incidentType: data[HseIncidentFields.incidentType.name] ?? '',
      incidentTypeExtra: data[HseIncidentFields.incidentTypeExtra.name] ?? '',
      damageOrInjury: data[HseIncidentFields.damageOrInjury.name] ?? '',
      preventionReccomendations: data[HseIncidentFields.preventionReccomendations.name] ?? '',
      immediateActionsIds: List<String>.from(data[HseIncidentFields.immediateActionsIds.name] ?? []),
      imgUrl: data[HseIncidentFields.imgUrl.name] ?? '',
      );
}

enum HseIncidentFields {
  id,
  createdAt,
  createdById,
  location,
  locationExtra,
  details,
  incidentType,
  incidentTypeExtra,
  damageOrInjury,
  immediateActionsIds,
  preventionReccomendations,
  imgUrl,
}

extension HseIncidentFieldsExtension on HseIncidentFields {
  String get name {
    // Map-based lookup
    return {
      HseIncidentFields.id: 'id',
      HseIncidentFields.createdAt: 'createdAt',
      HseIncidentFields.createdById: 'createdById',
      HseIncidentFields.location: 'location',
      HseIncidentFields.locationExtra: 'locationExtra',
      HseIncidentFields.details: 'details',
      HseIncidentFields.incidentType: 'incidentType',
      HseIncidentFields.incidentTypeExtra: 'incidentTypeExtra',
      HseIncidentFields.damageOrInjury: 'damageOrInjury',
      HseIncidentFields.immediateActionsIds: 'immediateActionsIds',
      HseIncidentFields.preventionReccomendations: 'preventionReccomendations',
      HseIncidentFields.imgUrl: 'imgUrl',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}