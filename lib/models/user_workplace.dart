import 'model_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class UserWorkplace extends ModelBase{
    
  static const collectionString = 'UserWorkplaces';

  static const empty = UserWorkplace(id: '',workpalceId:'',userId:'',role:'');

  ///region Getters
  @override
  bool get isEmpty => this == UserWorkplace.empty ;
  @override
  bool get isNotEmpty => this != UserWorkplace.empty;


  const UserWorkplace({
    required this.id,
    this.createdAt,
    
    required this.workpalceId,
    required this.userId,
    required this.role,
    this.invitationCode = '',
    this.quizeGamelevel = const {},
    this.points = 0,
    this.assignedMiniSessions = const [],
    this.takenMiniSessions = const [],

  });
  final String id;
  final DateTime? createdAt;
  final String workpalceId;
  final String userId;
  final String role;
  final String invitationCode;
  final Map<String, int> quizeGamelevel;
  final int points;
  final List<String> assignedMiniSessions;
  final List<String> takenMiniSessions;

    @override
  List<Object?> get props => [
    id,
    createdAt,
    workpalceId,
    userId,
    role,
    invitationCode,
    quizeGamelevel,
    points,
    assignedMiniSessions,
    takenMiniSessions,
  ];
  @override
  Map<String, dynamic> toMap()=> {
      UserWorkPlaceFields.id.name: id,
      UserWorkPlaceFields.createdAt.name: Timestamp.fromDate(createdAt!),
      UserWorkPlaceFields.workpalceId.name: workpalceId,
      UserWorkPlaceFields.userId.name: userId,
      UserWorkPlaceFields.role.name: role,
      UserWorkPlaceFields.invitationCode.name: invitationCode,
      UserWorkPlaceFields.points.name: points,
      UserWorkPlaceFields.quizeGamelevel.name: quizeGamelevel,
      UserWorkPlaceFields.assignedMiniSessions.name: assignedMiniSessions,
      UserWorkPlaceFields.takenMiniSessions.name: takenMiniSessions,
  };

  @override
  factory UserWorkplace.fromMap(Map<dynamic, dynamic> data) => UserWorkplace(
      id: data[UserWorkPlaceFields.id.name],
      createdAt:(data[UserWorkPlaceFields.createdAt.name] as Timestamp).toDate(),
      workpalceId: data[UserWorkPlaceFields.workpalceId.name],
      userId: data[UserWorkPlaceFields.userId.name],
      role: data[UserWorkPlaceFields.role.name],
      invitationCode: data[UserWorkPlaceFields.invitationCode.name]??'',
      points: data[UserWorkPlaceFields.points.name]??0,
      quizeGamelevel:  data[UserWorkPlaceFields.quizeGamelevel.name] != null?
        Map<String, int>.from(data[UserWorkPlaceFields.quizeGamelevel.name] as Map) : {},
      assignedMiniSessions: data[UserWorkPlaceFields.assignedMiniSessions.name] != null?
        List<String>.from(data[UserWorkPlaceFields.assignedMiniSessions.name]) :[],
      takenMiniSessions: data[UserWorkPlaceFields.takenMiniSessions.name] != null?
        List<String>.from(data[UserWorkPlaceFields.takenMiniSessions.name]):[] ,
      );
}

enum UserWorkPlaceFields {
  id,
  createdAt,
  workpalceId,
  userId,
  role,
  invitationCode,
  quizeGamelevel,
  points,
  assignedMiniSessions,
  takenMiniSessions,
}

extension UserWorkPlaceFieldsExtension on UserWorkPlaceFields {
  String get name {
    return {
      UserWorkPlaceFields.id: 'id',
      UserWorkPlaceFields.createdAt: 'createdAt',
      UserWorkPlaceFields.workpalceId: 'workpalceId',
      UserWorkPlaceFields.userId: 'userId',
      UserWorkPlaceFields.role: 'role',
      UserWorkPlaceFields.invitationCode: 'invitationCode',
      UserWorkPlaceFields.quizeGamelevel: 'quizeGamelevel',
      UserWorkPlaceFields.points: 'points',
      UserWorkPlaceFields.assignedMiniSessions: 'assignedMiniSessions',
      UserWorkPlaceFields.takenMiniSessions: 'takenMiniSessions',
    }[this]!; 
  }
}