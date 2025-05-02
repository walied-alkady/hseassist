import 'package:equatable/equatable.dart';
import 'package:hseassist/models/models.dart';


abstract  class ModelBase extends Equatable{
  
  static String get idString => 'id';
  const ModelBase();
  //endregion
  ///region Getters
  /// Convenience getter to determine whether the current is empty.
  bool get isEmpty;
  /// Convenience getter to determine whether the current is not empty.
  bool get isNotEmpty ;
  ///endregion
  
  Map<String, dynamic> toMap();
  
  factory ModelBase.fromMap(Map<String, dynamic> map) {
    // This will be implemented by subclasses
    throw UnimplementedError(); 
  }

  factory ModelBase.createModel(String collectionName,Map<String, dynamic> mapIn) {
    Map<String, dynamic> map = Map<String, dynamic>.from(mapIn);
    switch (collectionName) {
      case AuthUser.collectionString : return  AuthUser.fromMap(map) ;
      case Workplace.collectionString : return  Workplace.fromMap(map) ;
      case WorkplaceInvitation.collectionString : return  WorkplaceInvitation.fromMap(map) ;
      case HseIncident.collectionString : return  HseIncident.fromMap(map) ;
      case HseHazard.collectionString : return  HseHazard.fromMap(map) ;
      case HseTask.collectionString : return  HseTask.fromMap(map) ;
      case UserWorkplace.collectionString : return  UserWorkplace.fromMap(map) ;
      case WorkplaceLocation.collectionString : return  WorkplaceLocation.fromMap(map) ;
      case WorkplaceSetting.collectionString : return  WorkplaceSetting.fromMap(map) ;
      case ChatMessage.collectionString : return  ChatMessage.fromMap(map) ;
      default: throw UnimplementedError('Model type not supported for map: $map');
    }
  }
}

extension ModelBaseExtension on ModelBase{

  
  // String? collectionName<T>() {
  //   final _collectionMap = <Type, String>{ // Lookup map
  //     AuthUser: AuthUser.collectionString,  // Access static members directly
  //     Workplace: Workplace.collectionString,
  //     WorkplaceInvitation: WorkplaceInvitation.collectionString,
  //     HseIncident: HseIncident.collectionString,
  //     HseHazard: HseHazard.collectionString,
  //     HseTask: HseTask.collectionString,
  //   };
  //   return _collectionMap[T];
  // }

  // String collectionPath<T>({String workplaceId=''}){
  //   final _dummyModelByType = <Type, ModelBase>{
  //     AuthUser: AuthUser.empty,
  //     Workplace: Workplace.empty,
  //     WorkplaceInvitation: WorkplaceInvitation.empty,
  //     UserToWorkPlace: UserToWorkPlace.empty,
  //     HseIncident: HseIncident.empty,
  //     HseHazard: HseHazard.empty,
  //     HseTask: HseTask.empty, 
  //   };
  //     final _collectionMap = <Type, String>{ // Lookup map
  //     AuthUser: AuthUser.collectionString,  // Access static members directly
  //     Workplace: Workplace.collectionString,
  //     WorkplaceInvitation: WorkplaceInvitation.collectionString,
  //     HseIncident: HseIncident.collectionString,
  //     HseHazard: HseHazard.collectionString,
  //     HseTask: HseTask.collectionString,
  //   };
  //   final dummy = _dummyModelByType[T];
  //   if(dummy==null){
  //     return '';
  //   }
  //   final collName  = dummy.collectionName<T>();
  //   if(
  //     collName == Workplace.collectionString || 
  //     collName == WorkplaceInvitation.collectionString ||
  //     collName == UserToWorkPlace.collectionString
  //     ){
  //     return collName!;
  //   }else{
  //     return '${Workplace.collectionString}/$workplaceId/${collName}';
  //   } 
  // }
  
  // String documentPath<T>({String workplaceId=''}){
  //     final _collectionMap = <Type, String>{ // Lookup map
  //     AuthUser: AuthUser.collectionString,  // Access static members directly
  //     Workplace: Workplace.collectionString,
  //     WorkplaceInvitation: WorkplaceInvitation.collectionString,
  //     HseIncident: HseIncident.collectionString,
  //     HseHazard: HseHazard.collectionString,
  //     HseTask: HseTask.collectionString,
  //   };
  //   if(_collectionMap[T]==null){
  //     return '';
  //   }
  //   if(
  //     _collectionMap[T] == Workplace.collectionString || 
  //     _collectionMap[T] == WorkplaceInvitation.collectionString ||
  //     _collectionMap[T] == UserToWorkPlace.collectionString
  //     ){
  //     return "${_collectionMap[T]}/$id";
  //   }else{
  //     return '${Workplace.collectionString}/$workplaceId/${_collectionMap[T]}/$id';
  //   } 
  // }
  
  bool get isAuthUser{
    return this is AuthUser;
  }
  bool get isHseHazard{
    return this is HseHazard;
  }
  bool get isHseIncident{
    return this is HseIncident;
  }
  bool get isHseTask{
    return this is HseTask;
  }
  bool get isWorkplace{
    return this is Workplace;
  }
  bool get isWorkplaceInvitation{
    return this is WorkplaceInvitation;
  }
  bool get isUserToWorkPlace{
    return this is UserWorkplace;
  }
  bool get isWorkplaceLocation{
    return this is WorkplaceLocation;
  }
  bool get isWorkplaceSetting{
    return this is WorkplaceSetting;
  }
  bool get isChatMessage{
    return this is ChatMessage;
  }

}

