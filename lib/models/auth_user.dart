import 'package:hseassist/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUser extends ModelBase  { 
  
  static const collectionString = 'authUsers';

  static var empty = AuthUser(id:'',email: '',uid: '',provider: 'none');

  ///region Getters
  @override
  bool get isEmpty => this == AuthUser.empty ;
  @override
  bool get isNotEmpty => this != AuthUser.empty;


  //region constructor
  const AuthUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.displayName,
    this.displayNameLocal,
    this.phoneNumber,
    this.photoURL,
    this.isEmailVerified,
    this.isAnonymous,
    required this.uid,
    this.notes,
    required this.provider,
    this.fcmToken,
    this.currentWorkplace,
    this.currentWorkplaceDataId,
    this.currentWorkplaceRole,
    this.currentWorkplaceInvitationCode,
    this.assignedMiniSessions,
    this.takenMiniSessions,
    this.currentWorkplacePoints,
    this.isFirstLogin = true,
    this.createdAt,
    this.updatedAt,
    
  });
  //endregion
  final String email;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? displayNameLocal;
  final String? phoneNumber;
  final String? photoURL;
  final bool? isEmailVerified;
  final bool? isAnonymous;
  final String uid;
  final String? notes;
  final String provider;
  final String? currentWorkplace;
  final String? currentWorkplaceRole;
  final String? currentWorkplaceInvitationCode;  
  final String? fcmToken;  
  final String id; 
  final List<String>? assignedMiniSessions; 
  final List<String>? takenMiniSessions; 
  final String? currentWorkplaceDataId; 
  final int? currentWorkplacePoints; 
  final bool isFirstLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // endregion

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    displayName,
    displayNameLocal,
    phoneNumber,
    photoURL,
    isEmailVerified,
    isAnonymous,
    uid,
    notes,
    provider,
    fcmToken,
    currentWorkplace,
    currentWorkplaceDataId,
    currentWorkplaceRole,
    currentWorkplaceInvitationCode,
    assignedMiniSessions,
    takenMiniSessions,
    isFirstLogin,
    createdAt,
    updatedAt,
  ];

  @override
  Map<String, dynamic> toMap() => {
      AuthUserFields.id.name: id,
      AuthUserFields.email.name: email,
      if (firstName != null) AuthUserFields.firstName.name: firstName,
      if (lastName != null) AuthUserFields.lastName.name: lastName,
      if (displayName != null) AuthUserFields.displayName.name: displayName,
      if (displayNameLocal != null) AuthUserFields.displayNameLocal.name: displayNameLocal,
      if (phoneNumber != null) AuthUserFields.phoneNumber.name: phoneNumber,
      if (photoURL != null) AuthUserFields.photoURL.name: photoURL,
      if (isEmailVerified != null) AuthUserFields.isEmailVerified.name: isEmailVerified,
      if (isAnonymous != null) AuthUserFields.isAnonymous.name: isAnonymous,
      AuthUserFields.uid.name: uid,
      if (notes != null) AuthUserFields.notes.name: notes,
      AuthUserFields.provider.name : provider,
      if (fcmToken != null) AuthUserFields.fcmToken.name: fcmToken, 
      if (currentWorkplace != null) AuthUserFields.currentWorkplace.name: currentWorkplace,
      if (currentWorkplaceDataId != null) AuthUserFields.currentWorkplaceDataId.name: currentWorkplaceDataId,
      if (currentWorkplaceRole != null) AuthUserFields.currentWorkplaceRole.name: currentWorkplaceRole,
      if (currentWorkplaceInvitationCode != null) AuthUserFields.currentWorkplaceInvitationCode.name: currentWorkplaceInvitationCode,
      if (assignedMiniSessions != null) AuthUserFields.assignedMiniSessions.name: assignedMiniSessions,
      if (takenMiniSessions != null) AuthUserFields.takenMiniSessions.name: takenMiniSessions,
      AuthUserFields.isFirstLogin.name: isFirstLogin, 
      AuthUserFields.createdAt.name:Timestamp.fromDate(createdAt!),
      if (updatedAt!=null) AuthUserFields.updatedAt.name:Timestamp.fromDate(updatedAt!),

    };
  
  @override
  factory AuthUser.fromMap(Map<dynamic, dynamic> data){ 
    return AuthUser(
      id: data[AuthUserFields.id.name],
      email: data[AuthUserFields.email.name],
      firstName: data[AuthUserFields.firstName.name],
      lastName: data[AuthUserFields.lastName.name],
      displayName: data[AuthUserFields.displayName.name],
      displayNameLocal: data[AuthUserFields.displayNameLocal.name],
      phoneNumber: data[AuthUserFields.phoneNumber.name],
      photoURL: data[AuthUserFields.photoURL.name],
      isEmailVerified: data[AuthUserFields.isEmailVerified.name],
      isAnonymous: data[AuthUserFields.isAnonymous.name],
      uid: data[AuthUserFields.uid.name],
      notes: data[AuthUserFields.notes.name],
      provider : data[AuthUserFields.provider.name],
      fcmToken: data[AuthUserFields.fcmToken.name],
      currentWorkplace: data[AuthUserFields.currentWorkplace.name]??'',
      currentWorkplaceDataId: data[AuthUserFields.currentWorkplaceDataId.name]??'',
      currentWorkplaceRole: data[AuthUserFields.currentWorkplaceRole.name]??'',
      currentWorkplaceInvitationCode: data[AuthUserFields.currentWorkplaceInvitationCode.name]??'',
      assignedMiniSessions: data[AuthUserFields.assignedMiniSessions.name]??[],
      takenMiniSessions: data[AuthUserFields.takenMiniSessions.name]??[],
      isFirstLogin: data[AuthUserFields.isFirstLogin.name]??true,
      createdAt: (data[AuthUserFields.createdAt.name] as Timestamp).toDate(),
      updatedAt:  (data[AuthUserFields.updatedAt.name]  as Timestamp?)?.toDate(),
      );}

  @override
  bool get stringify => true;

}

enum AuthUserFields {
    id,
    email,
    firstName,
    lastName,
    displayName,
    displayNameLocal,
    phoneNumber,
    photoURL,
    isEmailVerified,
    isAnonymous,
    uid,
    notes,
    provider,
    fcmToken,
    currentWorkplace,
    currentWorkplaceDataId,
    currentWorkplaceRole,
    currentWorkplaceInvitationCode,
    assignedMiniSessions,
    takenMiniSessions,
    isFirstLogin,
    createdAt,
    updatedAt,

}

extension AuthUserFieldsExtension on AuthUserFields {
  String get name {
    // Map-based lookup
    return {
      AuthUserFields.id: 'id',
      AuthUserFields.email: 'email',
      AuthUserFields.firstName: 'firstName',
      AuthUserFields.lastName: 'lastName',
      AuthUserFields.displayName: 'displayName',
      AuthUserFields.displayNameLocal: 'displayNameLocal',
      AuthUserFields.phoneNumber: 'phoneNumber',
      AuthUserFields.photoURL: 'photoURL',
      AuthUserFields.isEmailVerified: 'isEmailVerified',
      AuthUserFields.isAnonymous: 'isAnonymous',
      AuthUserFields.uid: 'uid',
      AuthUserFields.notes: 'notes',
      AuthUserFields.provider: 'provider',
      AuthUserFields.fcmToken: 'fcmToken',      
      AuthUserFields.currentWorkplace: 'currentWorkplace',
      AuthUserFields.currentWorkplaceDataId: 'currentWorkplaceDataId',
      AuthUserFields.currentWorkplaceRole: 'currentWorkplaceRole',
      AuthUserFields.currentWorkplaceInvitationCode: 'currentWorkplaceInvitationCode',
      AuthUserFields.assignedMiniSessions: 'assignedMiniSessions',
      AuthUserFields.takenMiniSessions: 'takenMiniSessions',
      AuthUserFields.isFirstLogin: 'isFirstLogin',
      AuthUserFields.createdAt: 'createdAt',
      AuthUserFields.updatedAt: 'updatedAt',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}

