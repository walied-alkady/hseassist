import 'dart:async';
import 'dart:io'; 
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/models/workplace.dart';
import '../enums/form_status.dart';
import '../models/workplace_location.dart';
import '../repository/logging_reprository.dart';
import 'manager.dart';
import 'package:flutter/material.dart';

class UserAdminIntroUpdate extends Equatable{
  final int currentPage;
  final bool showNextButton;
  final bool showNavButtons;
  final bool verificationMailSent;
  final File? selectedLogo; 
  final double? uploadProgress;
  final String workplaceActivityType;
  final List<String> locations;
  final FormStatus status;
  final String? errorMessage;

  const UserAdminIntroUpdate({
    this.currentPage = 0,
    this.showNextButton = false,
    this.showNavButtons = true,
    this.verificationMailSent = false,
    this.selectedLogo,
    this.uploadProgress,
    this.workplaceActivityType = '',
    this.locations = const [],
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [ status,errorMessage, currentPage, 
    selectedLogo, uploadProgress, showNextButton, workplaceActivityType, locations,showNavButtons,verificationMailSent];

  UserAdminIntroUpdate copyWith({
    int? currentPage,
    bool? showNextButton,
    bool? showNavButtons,
    bool? verificationMailSent,
    File? selectedLogo,
    double? uploadProgress,
    String? workplaceActivityType,
    List<String>? locations,
    FormStatus? status,
    String? errorMessage,
  }) {
    return UserAdminIntroUpdate(
      currentPage: currentPage ?? this.currentPage,
      showNextButton: showNextButton ?? this.showNextButton,
      showNavButtons: showNavButtons ?? this.showNavButtons,
      verificationMailSent: verificationMailSent ?? this.verificationMailSent,
      selectedLogo: selectedLogo ?? this.selectedLogo,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      workplaceActivityType: workplaceActivityType ?? this.workplaceActivityType,
      locations: locations ?? this.locations,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UserAdminIntroCubit extends Cubit<UserAdminIntroUpdate> with Manager<UserAdminIntroCubit>{
  
  final PageController pageController = PageController();
  final TextEditingController itemController = TextEditingController();
  Timer? _timer;
  UserAdminIntroCubit() : super(const UserAdminIntroUpdate());

  final _log = LoggerReprository('UserAdminIntroCubit');

  Future<void> initForm() async {
    try{
      _log.i('loading ...');
      emit(state.copyWith(status: FormStatus.inProgress));
      if(authService.currentAuthUser?.emailVerified == false) {
        emit(state.copyWith(showNavButtons:false));
        _log.i('checking verification ...');
        await _startVerificationCheck();
      }
      _log.i('Done initForm...');
    }catch(e){
      _log.i('Loading error...');
    }finally{
      emit(state.copyWith(status: FormStatus.initial));
    }
  }

  void updateCurrentPage(int page){
    emit(state.copyWith(currentPage: page));
  }

  void resendVerificationEmail() async {
    try {
      _log.i('sending email ...');
      emit(state.copyWith(status: FormStatus.inProgress));
      // Send verification email
      await authService.currentAuthUser?.sendEmailVerification();
      _log.i('Done...');
      emit(state.copyWith(verificationMailSent: true));
      // Show success message to the user
    } catch (e) {
      _log.e('$e');
      emit(state.copyWith(status: FormStatus.failure));
    }finally{
      emit(state.copyWith(status: FormStatus.initial));
      emit(state.copyWith(verificationMailSent: false));
    }

  }

  Future<void> _startVerificationCheck() async{
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await authService.currentAuthUser?.reload(); // Refresh user data
      if (authService.currentAuthUser?.emailVerified ?? false) {
        timer.cancel();
        pageController.animateToPage(0,duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        emit(state.copyWith(showNavButtons:true));
      }
    });
  }

  void updateWorkplaceActivity(String value){
    emit(state.copyWith(workplaceActivityType: value));
  }
  
  void addLocation(String value){  
    final alreadyExists =state.locations.any((element) => element.trim() == value);
    if(alreadyExists){
      emit(state.copyWith(errorMessage: 'errorMessages.alreadyExists'.tr()));
      _log.i("${state.errorMessage}");
      return;
    }
    emit(state.copyWith(
        locations: [...state.locations,value])
      );
  }

  void removeLocation(int index) {
    final updatedLocations = List<String>.from(state.locations);
    updatedLocations.removeAt(index);
    emit(state.copyWith(locations: updatedLocations));
  }
  
  Future<void> saveConfigurations() async {
   // if (!state.status.isInValide) return;
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      _log.i('Getting workplace...');
      final workplaceId = db.currentUser?.currentWorkplace;
      if(workplaceId!=null) {
        _log.i('got workplace id:$workplaceId, saving selected activity type...');
        await db.updateOne<Workplace>(workplaceId,{
          WorkplaceFields.activityType.name: state.workplaceActivityType,
        });
        _log.i('activity type saved...');
      }
      _log.i('saving locations...');
      if(state.locations.isNotEmpty){
      await _updateLocations();
      }
      _log.i('locations saved');
      _log.i('saving logo');
      if( state.selectedLogo !=null ){
            await storage.uploadImage( 
              imageFile: state.selectedLogo!.readAsBytesSync(),
              photoPath: "${db.currentWorkplaceId}",
              photoName: 'logo.png',
              onProgress: (progress){
                emit(state.copyWith(uploadProgress: progress));
              }
            )
            .then((onValue) async {
              await db.updateOne<Workplace>(db.currentWorkplaceId!, {WorkplaceFields.logoUrl.name: "${db.currentWorkplaceId}/"});
            });
        }
        _log.i('logo saved');
      _log.i('initGeminiService...');
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

  Future<void> _updateLocations() async{
    emit(state.copyWith(status: FormStatus.inProgress));
      try {
        final List<WorkplaceLocation> locations = [];
        for (var location in state.locations) {
          locations.add(WorkplaceLocation(id:'' ,description: location));
        }
        await db.createMultiple<WorkplaceLocation>(locations);
      } catch (e) {
        emit(state.copyWith(status: FormStatus.failure, errorMessage: 'Error adding locations: $e'));
      }finally{
        emit(state.copyWith(status: FormStatus.initial,errorMessage: null));
      }
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await super.close();
  }
  
}