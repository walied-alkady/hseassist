import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Exceptions/authentication_exception.dart';
import '../enums/form_status.dart';
import '../enums/provider_type.dart';
import '../repository/logging_reprository.dart';
import 'manager.dart';


class RegisterFormUpdate extends Equatable{
  final AutovalidateMode autovalidateMode;
  final String firstName;
  final String lastName;
  final String email;
  final bool enableEmail;
  final String password;
  final String confirmPassword;
  final bool isNewWorkplace;
  final String workplaceName;
  final bool obscureText;
  final FormStatus status;
  final String? errorMessage;

  const RegisterFormUpdate({
    this.autovalidateMode = AutovalidateMode.disabled,
    this.firstName = '',
    this.lastName = '',
    this.isNewWorkplace = false,
    this.workplaceName = '',
    this.email = '',
    this.enableEmail = true,
    this.password = '',
    this.confirmPassword = '',
    this.obscureText = true,
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        autovalidateMode,
        firstName,
        lastName,
        email,
        enableEmail,
        password,
        confirmPassword,
        workplaceName,
        isNewWorkplace,
        obscureText,
        status,
        errorMessage,
  ];

  RegisterFormUpdate copyWith({
    AutovalidateMode? autovalidateMode,
    String? firstName,
    String? lastName,
    String? email,
    bool? enableEmail,
    String? password,
    String? confirmPassword,
    bool? isNewWorkplace,
    String? workplaceName,
    bool? obscureText,
    FormStatus? status,
    String? errorMessage,
  }) {
    return RegisterFormUpdate(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      enableEmail: enableEmail ?? this.enableEmail,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      workplaceName: workplaceName ?? this.workplaceName,
      isNewWorkplace: isNewWorkplace ?? this.isNewWorkplace,
      obscureText: obscureText ?? this.obscureText,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RegisterCubit extends Cubit<RegisterFormUpdate> with Manager<RegisterCubit>{

  RegisterCubit() : super(const RegisterFormUpdate());
  final _log = LoggerReprository('RegisterCubit');

  void initForm() {
    if(authService.currentAuthUser!=null) {
      emit(state.copyWith(
        email: authService.currentAuthUser?.email,
        enableEmail: false,
        ));
    }
  }
  void updateEmail(String? email) {
    emit(state.copyWith(email: email));
  }

  void updatePassword(String? password) {
    emit(state.copyWith(password: password));
  }

  void updateConfirmPassword(String? confirmPassword) {
    emit(state.copyWith(confirmPassword: confirmPassword));
  }
  
  void updateFirstName(String? firstName) {
    emit(state.copyWith(firstName: firstName));
  }

  void updateLastName(String? lastName) {
    emit(state.copyWith(lastName: lastName));
  }

  void updateWorkplaceName(String? organizationName) {
    emit(state.copyWith(workplaceName: organizationName));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  void toggleObscureText() {
    emit(state.copyWith(obscureText: !state.obscureText));
  }

  void toggleIsNewWorkplace(){
    emit(state.copyWith(isNewWorkplace: !state.isNewWorkplace));
  }

  void reset() {
    emit(const RegisterFormUpdate());
  }

  Future<void> register(BuildContext context,{bool authenticated=false}) async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      _log.i('registering user by password...');
      User? authUser = authService.currentAuthUser;
      authUser ??= await authService.register(
          email: state.email,
          password: state.password,
          provider: ProviderType.password
        );
      if(authUser==null) {
            _log.i('could not be authorized...');
            throw UserNotFoundFailure('No user signed in.');   
      }
      
      if(state.isNewWorkplace){
          _log.i('creating new workplace admin user...');  
          String? idToken = await authUser.getIdToken();
          if(idToken?.isEmpty??false) throw UserNotFoundFailure('Failed to get ID token.');
          String fcmToken = '';
          if (defaultTargetPlatform == TargetPlatform.android) {
            fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
          }
          await db.registerAdminUser(
            userToken: idToken!,
            email: state.email, 
            firstName: state.firstName,
            lastName: state.lastName,
            newWorkplaceName: state.workplaceName,
            fcmToken: fcmToken
          );
      }else{
          _log.i('creating new user...');  
          await authService.register(
              password: state.password,
              email: state.email,
              provider: ProviderType.password,
              );
      }
      emit(state.copyWith(status: FormStatus.success));
    }
    on RegisterFirebaseFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormStatus.failure,
        ),
      ); 
    }
    on Exception catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          status: FormStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormStatus.failure));
    }finally{
      emit(state.copyWith(status: FormStatus.initial));
    }

  }


}