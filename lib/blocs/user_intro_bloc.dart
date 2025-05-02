import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../enums/form_status.dart';
import '../repository/logging_reprository.dart';
import 'manager.dart';
import 'package:flutter/material.dart';

class UserIntroUpdate extends Equatable{
  final int currentPage;
  final bool showNextButton;
  final String workplaceDescription;
  final List<String> locations;
  final FormStatus status;
  final String? errorMessage;

  const UserIntroUpdate({
    this.currentPage = 0,
    this.showNextButton = false,
    this.workplaceDescription = '',
    this.locations = const [],
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [ status,errorMessage, currentPage, showNextButton, workplaceDescription, locations];

  UserIntroUpdate copyWith({
    int? currentPage,
    bool? showNextButton,
    String? workplaceDescription,
    List<String>? locations,
    FormStatus? status,
    String? errorMessage,
  }) {
    return UserIntroUpdate(
      currentPage: currentPage ?? this.currentPage,
      showNextButton: showNextButton ?? this.showNextButton,
      workplaceDescription: workplaceDescription ?? this.workplaceDescription,
      locations: locations ?? this.locations,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UserIntroCubit extends Cubit<UserIntroUpdate> with Manager<UserIntroCubit>{
  
  final PageController pageController = PageController();
  final TextEditingController itemController = TextEditingController();
  
  UserIntroCubit() : super(const UserIntroUpdate());

  final _log = LoggerReprository('FirstUserLoginCubit');

  Future<void> initForm() async {
    try{
      _log.i('loading ...');
      emit(state.copyWith(status: FormStatus.inProgress ));
      _log.i('Done...');
    }catch(e){
      _log.i('Loading error...');
    }finally{
      emit(state.copyWith(status: FormStatus.initial));
    }
  }

  void updateCurrentPage(int page){
    emit(state.copyWith(currentPage: page));
  }

  Future<void> saveConfigurations() async {
   // if (!state.status.isInValide) return;
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
      if(db.currentUser?.currentWorkplace !=null) db.currentWorkplaceId = db.currentUser?.currentWorkplace;
      await initGeminiService();
      emit(state.copyWith(status: FormStatus.success));
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