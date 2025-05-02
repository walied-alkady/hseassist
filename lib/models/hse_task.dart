
import 'model_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class HseTask extends ModelBase{
    
  static const collectionString = 'hseTasks';

  static const empty = HseTask();

  ///region Getters
  @override
  bool get isEmpty => this == HseTask.empty ;
  @override
  bool get isNotEmpty => this != HseTask.empty;
  ///endregion


  const HseTask(
    {
      this.id='',
    this.createdAt ,
    this.dueDate,
    this.requesterId='',
    this.responsibleId='',
    this.hseRequestType='',
    this.hseRequestId='',
    this.details='',
    this.feedback='',
    this.status='',
  });
  final String id;
  final DateTime? createdAt;
  final DateTime? dueDate;
  final String requesterId;
  final String responsibleId;
  final String hseRequestType;
  final String hseRequestId;
  final String details;
  final String feedback;
  final String status;
  ///endregion

  @override
  List<Object?> get props => [
    id,
    createdAt,
    dueDate,
    requesterId,
    responsibleId,
    hseRequestType,
    hseRequestId,
    details,
    feedback,
    status,
  ];
  @override
  Map<String, dynamic> toMap()=> {
      HseTaskFields.id.name:id,
      HseTaskFields.createdAt.name:Timestamp.fromDate(createdAt!),
      if (dueDate!=null) HseTaskFields.dueDate.name:dueDate,
      HseTaskFields.requesterId.name:requesterId,
      HseTaskFields.responsibleId.name:responsibleId,
      HseTaskFields.hseRequestType.name:hseRequestType,
      HseTaskFields.hseRequestId.name:hseRequestId,
      HseTaskFields.details.name:details,
      HseTaskFields.feedback.name:feedback,
      HseTaskFields.status.name:status,
    };

  @override
  factory HseTask.fromMap(Map<dynamic, dynamic> data) => HseTask(
      id: data[HseTaskFields.id.name]??'',
      createdAt:(data[HseTaskFields.createdAt.name] as Timestamp).toDate(),
      dueDate: (data[HseTaskFields.createdAt.name] as Timestamp?)?.toDate(),
      requesterId: data[HseTaskFields.requesterId.name]??'',
      responsibleId: data[HseTaskFields.responsibleId.name]??'',
      hseRequestType: data[HseTaskFields.hseRequestType.name]??'',
      hseRequestId: data[HseTaskFields.hseRequestId.name]??'',
      details: data[HseTaskFields.details.name]??'',
      feedback: data[HseTaskFields.feedback.name]??'',
      status: data[HseTaskFields.status.name]??'',
      );    
}

enum HseTaskFields {
  id,
  createdAt,
  dueDate,
  requesterId,
  responsibleId,
  hseRequestType,
  hseRequestId,
  details,
  feedback,
  status,
}

extension HseTaskFieldsExtension on HseTaskFields {
  String get name {
    // Map-based lookup
    return {
      HseTaskFields.id: 'id',
      HseTaskFields.createdAt: 'createdAt',
      HseTaskFields.dueDate: 'dueDate',
      HseTaskFields.requesterId: 'requesterId',
      HseTaskFields.responsibleId: 'responsibleId',
      HseTaskFields.hseRequestType: 'hseRequestType',
      HseTaskFields.hseRequestId: 'hseRequestId',
      HseTaskFields.details: 'details',
      HseTaskFields.feedback: 'feedback',
      HseTaskFields.status: 'status',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}