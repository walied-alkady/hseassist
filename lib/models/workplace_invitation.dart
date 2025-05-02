import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import 'model_base.dart';

class WorkplaceInvitation extends ModelBase{
    
  static const collectionString = 'workplaceInvitations';

  static const empty = WorkplaceInvitation(
    id: '',
    workplaceId: '',
    invitedUserEmail: '',
    inviterId: '', 
    status: '', //(e.g., "pending", "accepted", "rejected")
    role: '',
  );

  ///region Getters
  @override
  bool get isEmpty => this == WorkplaceInvitation.empty ;
  @override
  bool get isNotEmpty => this != WorkplaceInvitation.empty;
  ///endregion
  const WorkplaceInvitation(
    {
      required this.id,
      required this.workplaceId,
      required this.invitedUserEmail,
      required this.inviterId,
      this.createdAt,
      required this.status,
      required this.role,    
  });
  final String id;
  final String workplaceId;
  final String invitedUserEmail;
  final String inviterId;
  final DateTime? createdAt;
  final String status;
  final String role;
  
  @override
  List<Object?> get props => [
    id,
    workplaceId,
    invitedUserEmail, 
    inviterId,
    createdAt,
    status,
    role,
  ];
  @override
  Map<String, dynamic> toMap()=> {
      WorkplaceInvitationFields.id.name: id,
      WorkplaceInvitationFields.workplaceId.name: workplaceId,
      WorkplaceInvitationFields.invitedUserEmail.name: invitedUserEmail,
      WorkplaceInvitationFields.inviterId.name: inviterId,
      WorkplaceInvitationFields.createdAt.name: Timestamp.fromDate(createdAt!),
      WorkplaceInvitationFields.status.name: status,
      WorkplaceInvitationFields.role.name: role,
    };
  @override
  factory WorkplaceInvitation.fromMap(Map<dynamic, dynamic> data) => WorkplaceInvitation(
      id: data[WorkplaceInvitationFields.id.name],
      workplaceId: data[WorkplaceInvitationFields.workplaceId.name],
      invitedUserEmail: data[WorkplaceInvitationFields.invitedUserEmail.name],
      inviterId: data[WorkplaceInvitationFields.inviterId.name],
      createdAt:(data[WorkplaceInvitationFields.createdAt.name] as Timestamp).toDate(),
      status: data[WorkplaceInvitationFields.status.name],
      role: data[WorkplaceInvitationFields.role.name],
      );
}


enum WorkplaceInvitationFields {
  id,
  workplaceId,
  expiryDate,
  invitedUserEmail,
  inviterId,
  createdAt,
  status,
  role,
}

extension WorkplaceInvitationFieldsExtension on WorkplaceInvitationFields {
    String get name {
    // Map-based lookup
    return {
      WorkplaceInvitationFields.id: 'id',
      WorkplaceInvitationFields.workplaceId: 'workplaceId',
      WorkplaceInvitationFields.invitedUserEmail: 'invitedUserEmail',
      WorkplaceInvitationFields.inviterId: 'inviterId',
      WorkplaceInvitationFields.createdAt: 'createdAt',
      WorkplaceInvitationFields.status: 'status',
      WorkplaceInvitationFields.role: 'role',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}