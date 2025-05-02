import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../enums/form_status.dart';
import '../repository/logging_reprository.dart';
import 'manager.dart';

class ForgotPasswordFormUpdate extends Equatable {
  final AutovalidateMode autovalidateMode;
  final String email;
  final FormStatus status;
  final String? errorMessage;

  const ForgotPasswordFormUpdate({
    this.autovalidateMode = AutovalidateMode.disabled, 
    this.email = '',
    
    this.errorMessage,
    this.status = FormStatus.initial,
  });

  @override
  List<Object?> get props => [email, status, errorMessage,autovalidateMode];

  ForgotPasswordFormUpdate copyWith({
    AutovalidateMode? autovalidateMode,
    String? email,
    FormStatus? status,
    String? errorMessage,
  }) {
    return ForgotPasswordFormUpdate(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordFormUpdate> with Manager<ForgotPasswordCubit> {
  ForgotPasswordCubit() : super(const ForgotPasswordFormUpdate());
  final _log = LoggerReprository('AppCubit');
  void initForm() async {

  }  

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  void updateEmail(String? email) {
    emit(state.copyWith(email: email));
  }

  void reset() {
    emit(const ForgotPasswordFormUpdate());
  }

  Future<void> submit() async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      await authService.resetPass(state.email);
      emit(state.copyWith(status: FormStatus.success));
    } on FirebaseAuthException catch (e) {
      _log.e(e.toString());
      emit(state.copyWith(
          status: FormStatus.failure, errorMessage: e.code));
    } finally{
      emit(state.copyWith(status: FormStatus.initial));
    }
  }
}
