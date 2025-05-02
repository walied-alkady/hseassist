
import 'package:cloud_firestore/cloud_firestore.dart';

import 'model_base.dart';

class Workplace extends ModelBase{
    
  static const collectionString = 'workplaces';

  static const empty = Workplace();

  ///region Getters
  @override
  bool get isEmpty => this == Workplace.empty ;
  @override
  bool get isNotEmpty => this != Workplace.empty;

  const Workplace({
    this.id='',
    this.description='',
    this.activityType='',
    this.adminUserId='',
    this.createdAt,
    this.logoUrl,
  });
  final String id;
  final String description;
  final String activityType;
  final String adminUserId;
  final DateTime? createdAt;
  final String? logoUrl;

    @override
  List<Object?> get props => [
    id,
    description,
    activityType,
    adminUserId,
    createdAt,
    logoUrl,
  ];
  @override
  Map<String, dynamic> toMap()=> {
      WorkplaceFields.id.name: id,
      WorkplaceFields.description.name: description,
      WorkplaceFields.activityType.name: activityType,
      WorkplaceFields.adminUserId.name: adminUserId,
      WorkplaceFields.createdAt.name:Timestamp.fromDate(createdAt!),
      WorkplaceFields.logoUrl.name:logoUrl,
    };

  @override
  factory Workplace.fromMap(Map<dynamic, dynamic> data) => Workplace(
      id: data[WorkplaceFields.id.name] ?? '',
      description: data[WorkplaceFields.description.name] ?? '',
      activityType: data[WorkplaceFields.activityType.name] ?? '',
      adminUserId: data[WorkplaceFields.adminUserId.name] ?? '',
      createdAt:(data[WorkplaceFields.createdAt.name] as Timestamp).toDate(),
      logoUrl: data[WorkplaceFields.logoUrl.name] ?? '',
      );
}

enum WorkplaceFields {
  id,
  description,
  activityType,
  adminUserId,
  createdAt,
  logoUrl,
}
extension WorkplaceFieldsExtension on WorkplaceFields {
    String get name {
    // Map-based lookup
    return {
      WorkplaceFields.id: 'id',
      WorkplaceFields.description: 'description',
      WorkplaceFields.activityType: 'activityType',
      WorkplaceFields.adminUserId: 'adminUserId',
      WorkplaceFields.createdAt: 'createdAt',
      WorkplaceFields.logoUrl: 'logoUrl',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}
