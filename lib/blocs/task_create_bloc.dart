import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/blocs/validator.dart';

import '../Exceptions/database_exception.dart';
import '../enums/form_status.dart'; 
import '../enums/task_status.dart';
import '../models/models.dart';
import '../repository/logging_reprository.dart';
import 'manager.dart';
import 'package:const_date_time/const_date_time.dart';

class TaskCreateFormUpdate extends Equatable{
  
  const TaskCreateFormUpdate({
    this.autovalidateMode = AutovalidateMode.disabled, 
    this.dueDate = const ConstDateTime(9999, 12, 31),
    this.hseRequestType = '',
    this.details = '',
    this.responsibleId='', 
    this.errorMessage,
    this.status = FormStatus.initial,
  });

  final AutovalidateMode autovalidateMode;
  final DateTime dueDate;
  final String hseRequestType;
  final String details;
  final String responsibleId;
  final FormStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        autovalidateMode,
        dueDate,
        hseRequestType,
        responsibleId,
        details,        
        status,
        errorMessage,
      ];

  TaskCreateFormUpdate copyWith({
    AutovalidateMode? autovalidateMode,
    DateTime? dueDate,
    String? hseRequestType,
    String? responsibleId,
    String? details,
    FormStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return TaskCreateFormUpdate(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      dueDate: dueDate ?? this.dueDate,
      hseRequestType: hseRequestType ?? this.hseRequestType,
      responsibleId: responsibleId ?? this.responsibleId,
      details: details ?? this.details,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      
    );
  }
}

class TaskCreateCubit extends Cubit<TaskCreateFormUpdate>  with Validator,Manager<TaskCreateCubit>{
  TaskCreateCubit({bool isManaged = false}
  ) : _isManaged = isManaged, super(const TaskCreateFormUpdate());  
  final bool _isManaged; 
  final _log = LoggerReprository('TaskCreateCubit');

  List<String> hseRequestTypeSelection = ['general','incident','hazard'];
  List<AuthUser> responsibles = [];
    final HttpsCallable _sendFCMTokenMessageCallable = FirebaseFunctions.instance.httpsCallable('sendFCMTokenMessageToUid'); // Create callable object

  void initForm() async {
    try{
      _log.i('loading ...');
      emit(state.copyWith(status: FormStatus.inProgress ));
      _log.i('updateing lists...');
      await loadLists();
      _log.i('Done...');
    }catch(e){
      _log.i('Loading error...');
    }finally{
      emit(state.copyWith(status: FormStatus.initial));
    }

  }
  
  Future<void> loadLists() async{
    await Future.wait<void>([
      db.findAll<AuthUser>().then((result) {
        responsibles.clear();
        _log.i('got ${result.length} users data...');  
        return responsibles.addAll(result);
        }),  
    ]).catchError(
        (error) {
        _log.e('Error: $error');
        return error;
      }
    );
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  void updateDueDate(DateTime? due) {
    emit(state.copyWith(dueDate: due));
  }
  
  void updateHseRequestType(String? hseRequestType) {
    emit(state.copyWith(hseRequestType: hseRequestType));
  }

  void updateResponsibleId(String? responsibleId) {
    emit(state.copyWith(responsibleId: responsibleId));
  }

  void updateDetails(String? details) {
    emit(state.copyWith(details: details));
  }

  void reset() {
    emit(const TaskCreateFormUpdate());
  }
  
  HseTask createManagedTask(){
    final newTask = HseTask(
            createdAt: DateTime.now(),
            dueDate: state.dueDate,
            responsibleId: state.responsibleId,
            details: state.details,
            requesterId : prefs.currentUserId,
            status : TaskStatus.pending.name,
    );
      return newTask;
  }

  Future<void> saveTask() async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      
      final newTask = HseTask(
            createdAt: DateTime.now(),
            dueDate: state.dueDate,
            hseRequestType: state.hseRequestType,
            responsibleId : state.responsibleId,
            details: state.details,
            requesterId : prefs.currentUserId,
            status : TaskStatus.pending.name,
      );
      await db.create<HseTask>(newTask);
      if(prefs.isEnableNotifcations) await sendNotification();
      emit(state.copyWith(status: FormStatus.success));
      
    } on DatabaseFailure catch (e) {
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
    }
  }

  Future<void> sendNotification() async {
      final HttpsCallableResult result = await _sendFCMTokenMessageCallable.call({
          'token': state.responsibleId,
          'title':'New task',
          'body':state.details,
          'notificationPriority': 'high',
          'notificationData': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK', // For handling notification clicks
                'id': '1', // You can add custom data here
                'status': 'done'
              }
        });
        if (result.data['status'] == 'success') {
          // Optionally, return userId. Modify the Cloud Function to return it if you need it.
          _log.i('Notification sent to: ${state.responsibleId}');  

        } else {
          final String errorMessage = result.data['message']; // Get detailed error message from Cloud Function.
          throw UserCreationDBFailure(errorMessage);  //Throw an exception to be caught by the caller
        }

  }

  void mainTutorialFinished(){
    prefs.setFirstTimeTaskCreate(false);
  }

}



