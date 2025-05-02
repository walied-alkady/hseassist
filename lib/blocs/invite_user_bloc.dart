import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../enums/form_status.dart';
import '../enums/user_role.dart';
import '../repository/logging_reprository.dart';
import 'manager.dart';

class InviteUserFormUpdate extends Equatable {
  const InviteUserFormUpdate({
    this.autovalidateMode = AutovalidateMode.disabled,
    this.email = '',
    this.role = '',
  
    this.status = FormStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });
  final AutovalidateMode autovalidateMode;
  final String email;
  final String role;

  final FormStatus status;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
    autovalidateMode,
        email,
        role,
        status,
        isValid,
        errorMessage,
      ];

  InviteUserFormUpdate copyWith({
    AutovalidateMode? autovalidateMode,
    String? email,
    String? role,
    String? group,

    FormStatus? status,
    bool? isValid,
    String? errorMessage,

  }) {
    return InviteUserFormUpdate(
      // invitation
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class InviteUserCubit extends Cubit<InviteUserFormUpdate> with Manager<InviteUserCubit>{
  final userRoles = UserRole.values.map((role) => role.name).toList();
  InviteUserCubit() :super(const InviteUserFormUpdate());
  final _log = LoggerReprository('InviteUserCubit');

  Future<void> initForm() async {
    try{
      userRoles.remove(UserRole.master.name);
      userRoles.remove(UserRole.admin.name);
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
  
  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  void reset() {
    emit(const InviteUserFormUpdate());
  }

  void updateEmail(String email) {
    emit(
      state.copyWith(email:email),
    );
  }

  void updateRole(String role) {
    emit(
      state.copyWith(role:role
      ),
    );
  }

  Future<void> sendInvitation() async {
    if (!state.isValid) return;
    _log.i('starting the sending process...');
    emit(state.copyWith(
      status: FormStatus.inProgress
      ));
    try {
        _log.i('checking current user auth...');
        if (prefs.currentUserId.isNotEmpty){
        _log.i('saving invitation to db...');  
        await db.createWorkplaceInvitation(
          invitedUserEmail: state.email,
          role: state.role,
          inviterId: prefs.currentUserId
        ).then((val) {
          if(val!=null && val.isNotEmpty){
            emit(state.copyWith(
            status: FormStatus.success
            ));
          return;  
          }
        }); 
      }else{
        _log.i('error at getting current user...');
        emit(state.copyWith(status: FormStatus.failure,errorMessage: 'current user is not available'));
      }
    } on Exception catch (e) {
      _log.i('error $e...');
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          status: FormStatus.failure,
        ),
      );
    } catch (e) {
        _log.i('error $e...');
        emit(state.copyWith(status: FormStatus.failure,errorMessage: 'general error'));

    }
  }
}