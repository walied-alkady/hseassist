import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../enums/form_status.dart';
import '../models/workplace_invitation.dart';
import '../service/preferences_service.dart';
import 'manager.dart';

class RecieveInvitationFormUpdate extends Equatable{
  final AutovalidateMode autovalidateMode;
  final String invitationStatus;
  final String workplaceName;
  final FormStatus status;
  final String? errorMessage;
  
  const RecieveInvitationFormUpdate({
    this.autovalidateMode = AutovalidateMode.disabled,
    this.invitationStatus = '',
    this.workplaceName = '',
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  RecieveInvitationFormUpdate copyWith({
    AutovalidateMode? autovalidateMode,
    String? invitationStatus,
    String? workplaceName,
    FormStatus? status,
    String? errorMessage,
  }) {
    return RecieveInvitationFormUpdate(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      invitationStatus: invitationStatus ?? this.invitationStatus,
      workplaceName: workplaceName ?? this.workplaceName,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    
    );
  }
  
  @override
  List<Object?> get props => [
        autovalidateMode,
        invitationStatus,
        workplaceName,
        status,
        errorMessage,
      ];
}

class RecieveInvitationCubit extends Cubit<RecieveInvitationFormUpdate> with Manager<RecieveInvitationCubit>{
  RecieveInvitationCubit(this.newInvitaiton) :super(const RecieveInvitationFormUpdate());

  Map<String,String> language ={LanguageCodes.enUS:'English',LanguageCodes.arEG:'عربى'};
  WorkplaceInvitation newInvitaiton;  
  List<String> statusSelection = ['approve'.tr(),'reject'.tr()];

  Future<void> initForm() async {
    // final org = await db.find<Workplace>(quary: WorkplaceFields.id.name, value :newInvitaiton.workplaceId);
    // emit(state.copyWith(
    //   workplaceName: "${"organizationInvitaionMessage".tr()} ${org?.description}!",
    //   invitationStatus: 'approve'.tr()
    // ));
  }
  
  void updateInvitationResponse(String? response) {
    emit(state.copyWith(invitationStatus: response));
  }

  void reset() {
    emit(const RecieveInvitationFormUpdate());
  }
  
  Future<void> submitResponse() async {
    emit(state.copyWith(status: FormStatus.inProgress));
      try {
        if(state.invitationStatus=='approve'.tr()){
          final curAuthUser = authService.currentAuthUser;
          if (curAuthUser!=null){
          //await authService.joinWorkplace(email: curAuthUser.email!, invitationCode: newInvitaiton.id);
          }else{
            emit(state.copyWith(status: FormStatus.failure
            ));
          }
        }else{
          //await db.delete<WorkplaceInvitation>(newInvitaiton);
        }
        
        emit(state.copyWith(status: FormStatus.success));
      } 
      on Exception catch (e) {
        emit(
          state.copyWith(
            errorMessage: e.toString(),
            status: FormStatus.failure,
          ),
        );
      } catch (e) {
        emit(state.copyWith(
          errorMessage: e.toString(),
          status: FormStatus.failure));
      }
  }

}