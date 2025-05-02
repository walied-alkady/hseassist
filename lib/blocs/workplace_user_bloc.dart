import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../enums/form_status.dart';
import '../enums/user_role.dart';
import '../models/auth_user.dart';
import '../repository/logging_reprository.dart';
import '../service/authentication_service.dart';
import '../service/database_service.dart';
import '../service/preferences_service.dart';
import 'manager.dart';

class WorkplaceUserUpdate extends Equatable {
  const WorkplaceUserUpdate({
    this.role = '',
  
    this.status = FormStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });
  
  final String role;

  final FormStatus status;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        role,
        status,
        isValid,
        errorMessage,
      ];

  WorkplaceUserUpdate copyWith({
    String? role,
    FormStatus? status,
    bool? isValid,
    String? errorMessage,

  }) {
    return WorkplaceUserUpdate(
      // invitation
      role: role ?? this.role,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class WorkplaceUserCubit extends Cubit<WorkplaceUserUpdate> with Manager<WorkplaceUserCubit>{
  
  final userRoles = [
    UserRole.adminAssistant.name,
    UserRole.locationManager.name,
    UserRole.locationUser.name
    ];
  AuthUser user;
  WorkplaceUserCubit(this.user,{
    required AuthenticationService  authService,
    required DatabaseService  db,
    required LoggerReprository  log,
    required PreferencesService  prefs,
  }) : super(const WorkplaceUserUpdate());
  final _log = LoggerReprository('WorkplaceUserCubit');

  Future<void> initForm() async {
    try{
      _log.i('loading ...');
      emit(state.copyWith(status: FormStatus.inProgress ));
      _log.i('Done...');
    }catch(e){
      _log.i('Loading error...');
    }finally{
      emit(state.copyWith(status: FormStatus.initial,
      role: userRoles[1]));
    }
  }

  void updateRole(String role) {
    emit(
      state.copyWith(role:role
      ),
    );
  }

  Future<void> updateUser() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormStatus.inProgress));
    //TODO: needs cloud functions
    try {
      // final foundUser = db.findUser(userId)
      // if (authService.currentDbUser.isNotEmpty){
      // final Map<String,dynamic> newUs = {
      //       'role': state.role,
      // };
      // db.updateUser(authService.currentUser.id,newUs);
      // emit(state.copyWith(status: FormStatus.success));
      // }else{
      //   emit(state.copyWith(status: FormStatus.failure));
      // }
    } on Exception catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          status: FormStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormStatus.failure));
    }
  }
}