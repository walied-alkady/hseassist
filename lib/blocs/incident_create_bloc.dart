import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/blocs/blocs.dart';
import 'package:hseassist/blocs/manager.dart';
import 'package:hseassist/blocs/validator.dart';
import '../Exceptions/database_exception.dart';
import '../enums/form_status.dart'; 
import '../enums/query_operator.dart';
import '../enums/task_request_type.dart';
import '../models/models.dart';
import 'package:collection/collection.dart';

import '../repository/logging_reprository.dart';

class IncidentCreateFormUpdate extends Equatable {
  const IncidentCreateFormUpdate({
    this.autovalidateMode = AutovalidateMode.disabled, 

    this.details = '',
    this.location = '',
    this.selectedlocation = const WorkplaceLocation(id:''),
    this.locationExtra = '',
    this.incidentType = '',
    this.incidentTypeExtra = '',
    this.damageOrInjury = '',
    this.preventionReccomendations = '',
    this.tasks = const [],
    this.tasksToAdd = const [],
    this.tasksToRemove = const [],
    this.dueDate = '',
    this.hseRequestType = '',
    this.responsibleId='', 
    this.errorMessage,
    this.status = FormStatus.initial,
    this.isEnabled = true,
    this.editingIncident = false,
    this.isAdmin = false,
    this.markForDelete = false,
    this.imageFile,
    this.uploadProgress
  });

  final AutovalidateMode autovalidateMode;
  final String details;
  final String location;
  final WorkplaceLocation selectedlocation;
  final String locationExtra;
  final String incidentType;
  final String incidentTypeExtra;
  final String damageOrInjury;
  final String preventionReccomendations;
  final String dueDate;
  final String hseRequestType;
  final String responsibleId;
  final FormStatus status;
  final String? errorMessage;
  final List<HseTask> tasks;
  final List<HseTask> tasksToAdd;
  final List<HseTask> tasksToRemove;
  final bool isEnabled;
  final bool editingIncident;
  final bool isAdmin;
  final bool markForDelete;
  final File? imageFile;
  final double? uploadProgress;
  @override
  List<Object?> get props => [
        autovalidateMode,
        details, 
        location,
        locationExtra,
        incidentType,
        incidentTypeExtra,
        damageOrInjury,
        preventionReccomendations,
        dueDate,
        hseRequestType,
        responsibleId,
        tasks ,   
        tasksToAdd,
        tasksToRemove,
        status,
        errorMessage,
        isEnabled,
        editingIncident,
        isAdmin,
        markForDelete,
        selectedlocation,
        imageFile,
        uploadProgress
      ];

  IncidentCreateFormUpdate copyWith({
    AutovalidateMode? autovalidateMode,
    String? details,
    String? location,
    WorkplaceLocation? selectedlocation,
    String? locationExtra,
    String? incidentType,
    String? incidentTypeExtra,
    String? damageOrInjury,
    String? preventionReccomendations,
    List<HseTask>? tasks,
    List<HseTask>? tasksToAdd,
    List<HseTask>? tasksToRemove,
    String? dueDate,
    String? hseRequestType,
    String? responsibleId,
    FormStatus? status,
    bool? isValid,
    String? errorMessage,
    bool? isEnabled,
    bool? isAdmin,
    bool? markForDelete,
    bool? editingincident,
    File? imageFile,
    double? uploadProgress
  }) {
    return IncidentCreateFormUpdate(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      details: details ?? this.details,
      location: location ?? this.location,
      selectedlocation: selectedlocation ?? this.selectedlocation,
      locationExtra: locationExtra ?? this.locationExtra,
      incidentType: incidentType ?? this.incidentType,
      incidentTypeExtra: incidentTypeExtra ?? this.incidentTypeExtra,
      tasks: tasks ?? this.tasks,
      tasksToAdd: tasksToAdd ?? this.tasksToAdd,
      tasksToRemove: tasksToRemove ?? this.tasksToRemove,
      dueDate: dueDate ?? this.dueDate,
      hseRequestType: hseRequestType ?? this.hseRequestType,
      responsibleId: responsibleId ?? this.responsibleId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isEnabled: isEnabled?? this.isEnabled,
      isAdmin: isAdmin ?? this.isAdmin,
      markForDelete: markForDelete ?? this.markForDelete,
      editingIncident: editingincident ?? this.editingIncident,
      imageFile: imageFile ?? this.imageFile,
      uploadProgress: uploadProgress ?? this.uploadProgress
    );
  }
}

class IncidentCreateCubit extends Cubit<IncidentCreateFormUpdate> with Validator, Manager<IncidentCreateCubit>{
  IncidentCreateCubit(
    {
      this.originalIncident,
      this.showAds = true
    }) :super(const IncidentCreateFormUpdate()){
      _log.name = 'IncidentCreateCubit';
      taskCubit = TaskCreateCubit();
    }

  final bool showAds; 
  final _log = LoggerReprository('IncidentCreateCubit');

  late TaskCreateCubit taskCubit ;
  WorkplaceSetting? currentWorkplaceSettings;

  List<WorkplaceLocation> workplaceLocations = [];
  List<String> incidentTypeSelection = ['Unsafe action','Unsafe Condition'];
  List<String> damageOrInjuryTypeSelection = ['First Aid','Medical Treatment','LTI','Restricted Work','Occupational Illness','Fatality' , 'Equipment Damage', 'Equipment malfunction' ];

  List<AuthUser> responsibles = [];
  List<HseTask>? incidentAssignedTasks;
  //for editing
  HseIncident? originalIncident;
  List<String> incidentsToDelete = [];
  // Add a new state property to hold the temporary image file
  File? tempImageFile;
  final HttpsCallable _sendFCMTokenMessageCallable = FirebaseFunctions.instance.httpsCallable('sendFCMTokenMessageToUid'); // Create callable object
  final HttpsCallable _sendTopicMessageCallable = FirebaseFunctions.instance.httpsCallable('sendFCMTopicMessage'); // Create callable object

  void initForm() async {
    try{
      _log.i('loading ...');
      emit(state.copyWith(status: FormStatus.inProgress));
      _log.i('updateing settings...');
      currentWorkplaceSettings = await db.findAll<WorkplaceSetting>().then(
        (list) => list.firstOrNull
      );
      emit(state.copyWith(
        isAdmin: db.currentUser?.currentWorkplaceRole == 'admin',
        status: FormStatus.inProgress ));
      if(showAds && defaultTargetPlatform == TargetPlatform.android) {
        createInterstitialAd();
      }
      _log.i('updateing lists...');
      await loadLists();
      _log.i('checking editable incident...');
      if(originalIncident !=null){
        incidentAssignedTasks = await db.findAll<HseTask>(query: 'hseRequestId' ,queryValue: originalIncident!.id,quaryOperator: QueryComparisonOperator.eq);
        final incidentAssignedTasksNo = incidentAssignedTasks?.length??0;
        _log.i(
          "selected location: ${workplaceLocations.where((val)=> val.description == originalIncident?.location).firstOrNull?.description}"
          );
        final initialLocation = workplaceLocations.firstWhereOrNull(
          (location) => location.description == originalIncident!.location);
        emit(state.copyWith(
            isEnabled: true,
            details: originalIncident?.details,
            location: originalIncident?.location,
            locationExtra: originalIncident?.locationExtra,
            incidentType: originalIncident?.incidentType,
            incidentTypeExtra: originalIncident?.incidentTypeExtra,
            selectedlocation: initialLocation
          ));
        if(
            (incidentAssignedTasksNo ==0 && ((originalIncident?.createdById == prefs.currentUserId) || 
            (db.currentUser?.currentWorkplaceRole == 'admin'))  )
          ){
          emit(state.copyWith(
            isEnabled: true,
          ));
        }else{
          emit(state.copyWith(
            isEnabled: false,
          ));   
        }
        List<HseTask> tasksTemp=[];
        if(incidentAssignedTasksNo > 0){
          for (HseTask tsk in incidentAssignedTasks??[]){
            tasksTemp.add(tsk);
          }
          emit(state.copyWith(
            tasks: tasksTemp
          ));
        }
      }
      
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
      db.findAll<WorkplaceLocation>().then((result) {
        workplaceLocations.clear();
        _log.i('got ${result.length} location data...');  
        return workplaceLocations.addAll(result);
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
  
  void updateDetails(String? details) {
    emit(state.copyWith(details: details));
  }

  void updateLocation(WorkplaceLocation? location) {
    emit(state.copyWith(
      selectedlocation: location,
      location: location?.description
      ));
  }
  
  void updateLocationExtra(String? locationExtra) {
    emit(state.copyWith(locationExtra: locationExtra));
  }
  
  void updateIncidentType(String? incidentType) {
    emit(state.copyWith(incidentType: incidentType));
  }
  
  void updateIncidentTypeExtra(String? incidentTypeExtra) {
    emit(state.copyWith(incidentTypeExtra: incidentTypeExtra));
  }
  
  void updateDamageOrInjury(String? damageOrInjury) {
    emit(state.copyWith(damageOrInjury: damageOrInjury));
  }
  
  void updatePreventionReccomendations(String? reccomendations) {
    emit(state.copyWith(preventionReccomendations: reccomendations));
  }

  Future<void> updatePhoto(BuildContext context) async { 
    _log.i('loading image');
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      await createInterstitialAd();
      final img= await pickImage();
      _log.i('Done loading got ${img!=null?'image':'no image'}');
      if(context.mounted && defaultTargetPlatform == TargetPlatform.android){
      await showInterstitialAd(context).then((_) {
        if (img != null) {
        emit(state.copyWith(imageFile: img));
        }
      });
      
      }
      //emit(state.copyWith(status: FormStatus.imagePreview)); // New status for modal navigation
    } on Exception catch (e) {
      _log.i(e.toString());
      
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          status: FormStatus.failure,
        ),
      );
    } 
    
    finally {
      emit(state.copyWith(status: FormStatus.initial));
    }
    
  }
  
  void addTask(HseTask task) {
    emit(
      state.copyWith(
        tasks: [...state.tasks, task] , 
        tasksToAdd: [...state.tasksToAdd, task]
        )
    );

  }

  void removeTask(int index) {
    final updatedTasks = List<HseTask>.from(state.tasks);
    updatedTasks.removeAt(index);
    emit(state.copyWith(tasks: updatedTasks));
  }
  
  void resetFormState(){
    emit(state.copyWith(
      status: FormStatus.initial
    ));
  }

  void reset() {
    emit(const IncidentCreateFormUpdate());
  }
  
  void startEditing(HseIncident incident) {
    emit(state.copyWith(editingincident: true)); // Assuming you have editingUser in your state
  }
  
  void markForDeletion(bool delete) {
    emit(state.copyWith(markForDelete: delete));
  }

  Future<void> saveIncident() async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      String incidentId;
      // deleting the whole doc
      if (state.markForDelete && originalIncident?.id != null) {
        for (String id in originalIncident!.immediateActionsIds){
          await db.deleteOne<HseTask>(id);
        }
        await db.deleteOne<HseIncident>(originalIncident!.id);
        return;
      }
      // new doc or editing
      if(originalIncident?.id == null){
        final newIncident = HseIncident(
            createdAt: DateTime.now(),
            createdById: prefs.currentUserId,  
            location: state.location,
            locationExtra: state.locationExtra,
            details: state.details,
            incidentType : state.incidentType,
            incidentTypeExtra : state.incidentTypeExtra ,
            damageOrInjury : state.damageOrInjury,
            preventionReccomendations : state.preventionReccomendations,
        );
        incidentId = await db.create<HseIncident>(newIncident)??'';
        if(incidentId.isEmpty){
          emit(state.copyWith(status: FormStatus.failure));
          return;
        }
        for (HseTask tsk in state.tasksToAdd){
            final taskMap = tsk.toMap();
            taskMap[HseTaskFields.hseRequestId.name] = incidentId;
            taskMap[HseTaskFields.hseRequestType.name] = TaskRequestType.incident.name;
            taskMap[HseTaskFields.requesterId.name] = prefs.currentUserId;
            final newTaskId = await db.create<HseTask>(HseTask.fromMap(taskMap));
            if(newTaskId == null){
              emit(state.copyWith(status: FormStatus.failure));
              return;
            }
            await db.updateOne<HseIncident>(originalIncident!.id, {HseIncidentFields.immediateActionsIds.name : FieldValue.arrayUnion([newTaskId]) } );
            if(prefs.isEnableNotifcations) await sendTaskNotification(tsk.responsibleId,tsk.details);
        }
        if( tempImageFile !=null ){
            await storage.uploadImage( 
              imageFile: tempImageFile!.readAsBytesSync(),
              photoPath: "${db.currentUser?.currentWorkplaceDataId}/incidents/",
              photoName: incidentId,
              onProgress: (progress){
                emit(state.copyWith(uploadProgress: progress));
              }
            ).whenComplete(() {
                tempImageFile = null;
              })
            .then((onValue) async {
              await db.updateOne<HseIncident>(incidentId, {HseIncidentFields.imgUrl.name: "${db.currentUser?.currentWorkplaceDataId}/incidents/$incidentId"});
            });
        }
        if(currentWorkplaceSettings !=null) {

          final curWpSet = await db.findOne<UserWorkplace>(db.currentUser!.currentWorkplaceDataId!);
          final incidentPoints = currentWorkplaceSettings!.createIncidentPoints;
          final curPoints = curWpSet?.points??0;
          final newPoints = curPoints + incidentPoints;
          await db.updateOne<UserWorkplace>(
            db.currentUser!.currentWorkplaceDataId!,
            {UserWorkPlaceFields.points.name: newPoints},
          );
        }
        // send notifcations
        if(prefs.isEnableNotifcations) await sendIncidentNotification(state.location,state.incidentType);
      }else{
       // 1. Create a map to track changes
      final updatedFields = <String, dynamic>{};

      // 2. Compare and add changed fields to the map
      if (state.location != originalIncident!.location) {
        updatedFields[HseIncidentFields.location.name] = state.location;
      }
      if (state.locationExtra != originalIncident!.locationExtra) {
        updatedFields[HseIncidentFields.locationExtra.name] = state.locationExtra;
      }
      if (state.details != originalIncident!.details) {
        updatedFields[HseIncidentFields.details.name] = state.details;
      }
      if (state.incidentType != originalIncident!.incidentType) {
        updatedFields[HseIncidentFields.incidentType.name] = state.incidentType;
      }
      if (state.incidentTypeExtra != originalIncident!.incidentTypeExtra) {
        updatedFields[HseIncidentFields.incidentTypeExtra.name] = state.incidentTypeExtra;
      }
      if (state.damageOrInjury != originalIncident!.damageOrInjury) {
        updatedFields[HseIncidentFields.damageOrInjury.name] = state.damageOrInjury;
      }
      if (state.preventionReccomendations != originalIncident!.preventionReccomendations) {
        updatedFields[HseIncidentFields.preventionReccomendations.name] = state.preventionReccomendations;
      }
      if(state.editingIncident && updatedFields.isNotEmpty) {
        await db.updateOne<HseIncident>(originalIncident!.id,updatedFields);
      }
      for (HseTask tsk in state.tasksToAdd){
          final taskMap = tsk.toMap();
          taskMap[HseTaskFields.hseRequestId.name] = originalIncident?.id;
          taskMap[HseTaskFields.hseRequestType.name] = TaskRequestType.incident.name;
          taskMap[HseTaskFields.requesterId.name] = prefs.currentUserId;
          final newTaskId = await db.create<HseTask>(HseTask.fromMap(taskMap));
          if(newTaskId == null){
            emit(state.copyWith(status: FormStatus.failure));
            return;
          }
          await db.updateOne<HseIncident>(originalIncident!.id, {HseIncidentFields.immediateActionsIds.name : FieldValue.arrayUnion([newTaskId]) } );
          if(prefs.isEnableNotifcations) await sendTaskNotification(tsk.responsibleId,tsk.details);
      }
      }
      
      incidentsToDelete.clear();
      
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
    finally {
      reset();
    }
  }

  Future<void> sendTaskNotification(String responsibleId, String taskDetails) async {
      final HttpsCallableResult result = await _sendFCMTokenMessageCallable.call({
          'token': responsibleId,
          'title':'New Incident task',
          'body':taskDetails,
          'notificationPriority': 'high',
          'notificationData': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK', // For handling notification clicks
                'id': '1', // You can add custom data here
                'status': 'done'
              }
        });
        if (result.data['status'] == 'success') {
          // Optionally, return userId. Modify the Cloud Function to return it if you need it.
          _log.i('Notification sent to: $responsibleId');  

        } else {
          final String errorMessage = result.data['message']; // Get detailed error message from Cloud Function.
          throw UserCreationDBFailure(errorMessage);  //Throw an exception to be caught by the caller
        }

  }
  
  Future<void> sendIncidentNotification(String locationTopic,String details) async {
      final HttpsCallableResult result = await _sendTopicMessageCallable.call({
          'topic': locationTopic,
          'title':'Incident at $locationTopic',
          'body':details,
          'notificationPriority': 'high',
          'notificationData': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK', // For handling notification clicks
                'id': '1', // You can add custom data here
                'status': 'done'
              }
        });
        if (result.data['status'] == 'success') {
          // Optionally, return userId. Modify the Cloud Function to return it if you need it.
          _log.i('Notification sent to: $locationTopic');  

        } else {
          final String errorMessage = result.data['message']; // Get detailed error message from Cloud Function.
          throw UserCreationDBFailure(errorMessage);  //Throw an exception to be caught by the caller
        }

  }

  void mainTutorialFinished(){
    prefs.setFirstTimeIncidentCreate(false);
  }
}