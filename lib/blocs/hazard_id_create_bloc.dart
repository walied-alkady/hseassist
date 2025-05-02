import 'dart:io';
import 'dart:math' show sqrt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/blocs/blocs.dart';
import 'package:hseassist/blocs/manager.dart';
import 'package:hseassist/blocs/validator.dart';
import 'package:hseassist/enums/hazard_status.dart';
import '../Exceptions/database_exception.dart';
import '../enums/form_status.dart'; 
import '../enums/query_operator.dart';
import '../enums/task_request_type.dart';
import '../models/models.dart';
import '../repository/logging_reprository.dart';
import 'package:collection/collection.dart';

class HazardIdCreateFormUpdate extends Equatable {
  const HazardIdCreateFormUpdate({
    this.autovalidateMode = AutovalidateMode.disabled, 
    this.details = '',
    this.location = '',
    this.selectedlocation = const WorkplaceLocation(id:''),
    this.locationExtra = '',
    this.hazardType = '',
    this.hazardTypeExtra = '',
    this.tasks = const [],
    this.tasksToAdd = const [],
    this.tasksToRemove = const [],
    this.dueDate = '',
    this.hseRequestType = '',
    this.responsibleId='', 
    this.errorMessage,
    this.status = FormStatus.initial,
    this.isEnabled = true,
    this.editingHazard = false,
    this.isAdmin = false,
    this.markForDelete = false,
    this.imageFile,
    this.updatedImage,
    this.uploadProgress
  });

  final AutovalidateMode autovalidateMode;
  final String details;
  final String location;
  final WorkplaceLocation selectedlocation;
  final String locationExtra;
  final String hazardType;
  final String hazardTypeExtra;
  final String dueDate;
  final String hseRequestType;
  final String responsibleId;
  final FormStatus status;
  final String? errorMessage;
  final List<HseTask> tasks;
  final List<HseTask> tasksToAdd;
  final List<HseTask> tasksToRemove;
  final bool isEnabled;
  final bool editingHazard;
  final bool isAdmin;
  final bool markForDelete;
  final File? imageFile;
  final File? updatedImage;
  final double? uploadProgress;
  @override
  List<Object?> get props => [
        autovalidateMode,
        details, 
        location,
        locationExtra,
        hazardType,
        hazardTypeExtra,
        dueDate,
        hseRequestType,
        responsibleId,
        tasks ,   
        tasksToAdd,
        tasksToRemove,
        status,
        errorMessage,
        isEnabled,
        editingHazard,
        isAdmin,
        markForDelete,
        selectedlocation,
        imageFile,
        updatedImage,
        uploadProgress
      ];

  HazardIdCreateFormUpdate copyWith({
    AutovalidateMode? autovalidateMode,
    String? details,
    String? location,
    WorkplaceLocation? selectedlocation,
    String? locationExtra,
    String? hazardType,
    String? hazardTypeExtra,
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
    bool? editingHazard,
    File? imageFile,
    File? updatedImage,
    double? uploadProgress
  }) {
    return HazardIdCreateFormUpdate(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      details: details ?? this.details,
      location: location ?? this.location,
      selectedlocation: selectedlocation ?? this.selectedlocation,
      locationExtra: locationExtra ?? this.locationExtra,
      hazardType: hazardType ?? this.hazardType,
      hazardTypeExtra: hazardTypeExtra ?? this.hazardTypeExtra,
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
      editingHazard: editingHazard ?? this.editingHazard,
      imageFile: imageFile ?? this.imageFile,
      updatedImage: updatedImage ?? this.updatedImage,
      uploadProgress: uploadProgress ?? this.uploadProgress
    );
  }
}

class HazardIdCreateCubit extends Cubit<HazardIdCreateFormUpdate> with Validator, Manager<HazardIdCreateCubit>{
  HazardIdCreateCubit(
    {
      this.originalHazard,
      this.showAds = false
    }) : super(const HazardIdCreateFormUpdate());
  final _log = LoggerReprository('HazardIdCreateCubit');
  final bool showAds; 
  late final TaskCreateCubit taskCubit  = TaskCreateCubit();
  WorkplaceSetting? currentWorkplaceSettings;

  List<WorkplaceLocation> workplaceLocations = [];
  List<String> hazardTypeSelection = ['slip trip & fall','mechanical','electrical','chemical','biological','other'];
  List<AuthUser> responsibles = [];
  List<HseTask>? hazardAssignedTasks;
  //for editing
  HseHazard? originalHazard;
  List<String> hazardsToDelete = [];
  // Add a new state property to hold the temporary image file
  File? tempImageFile;
  final HttpsCallable _sendFCMTokenMessageCallable = FirebaseFunctions.instance.httpsCallable('sendFCMTokenMessageToUid'); // Create callable object
  final HttpsCallable _checkSimilarHazardCallable = FirebaseFunctions.instance.httpsCallable('checkSimilarHazard');
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
      _log.i('checking editable hazard...');
      if(originalHazard !=null){
        hazardAssignedTasks = await db.findAll<HseTask>(query: 'hseRequestId' ,queryValue: originalHazard!.id,quaryOperator: QueryComparisonOperator.eq);
        final hazardAssignedTasksNo = hazardAssignedTasks?.length??0;
        _log.i(
          "selected location: ${workplaceLocations.where((val)=> val.description == originalHazard?.location).firstOrNull?.description}"
          );
        final initialLocation = workplaceLocations.firstWhereOrNull(
          (location) => location.description == originalHazard!.location);
        emit(state.copyWith(
            isEnabled: true,
            details: originalHazard?.details,
            location: originalHazard?.location,
            locationExtra: originalHazard?.locationExtra,
            hazardType: originalHazard?.hazardType,
            hazardTypeExtra: originalHazard?.hazardTypeExtra,
            selectedlocation: initialLocation
          ));
        if(
            (hazardAssignedTasksNo ==0 && ((originalHazard?.createdById == prefs.currentUserId) || 
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
        if(hazardAssignedTasksNo > 0){
          for (HseTask tsk in hazardAssignedTasks??[]){
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
  
  void updateHazardType(String? hazrdType) {
    emit(state.copyWith(hazardType: hazrdType));
  }
  
  void updateHazardTypeExtra(String? hazrdTypeExtra) {
    emit(state.copyWith(hazardTypeExtra: hazrdTypeExtra));
  }
  
  Future<void> updatePhoto(BuildContext context) async { 
    _log.i('loading image');
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      if(context.mounted && defaultTargetPlatform == TargetPlatform.windows){
        final img= await pickImage();
        if (img != null) {
        emit(state.copyWith(imageFile: img));
        }
        return;
      }  

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
  
  void updateExpandable(File? expandedImage){
    emit(state.copyWith(updatedImage: expandedImage));
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
    emit(state.copyWith(
      status: FormStatus.initial,
      errorMessage: null,
      autovalidateMode: AutovalidateMode.disabled
      ));
  }
  
  void startEditing(HseHazard hazard) {
    emit(state.copyWith(editingHazard: true)); // Assuming you have editingUser in your state
  }
  
  void markForDeletion(bool delete) {
    emit(state.copyWith(markForDelete: delete));
  }

  Future<void> saveHazard() async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      
      String hzId;   
      final currentUser = db.currentUser;
      if(currentUser ==null) throw Exception('Current user not found');
      // deleting the whole doc
      if (state.markForDelete && originalHazard?.id != null) {
        for (String id in originalHazard!.taskIds){
          await db.deleteOne<HseTask>(id);
        }
        await db.deleteOne<HseHazard>(originalHazard!.id);
        emit(state.copyWith(status: FormStatus.success));
        return;
      }
      // new hazard
      if(originalHazard?.id == null){

        final embedingData = await gemini?.getEmbeddings(
          "a ${state.hazardType} ${state.hazardTypeExtra} hazard with details ${state.details} at ${state.location} ${state.locationExtra}" 
        );

        final newHazard = HseHazard(
            createdAt: DateTime.now(),
            createdById: db.currentUser!.id,  
            location: state.location,
            locationExtra: state.locationExtra,
            details: state.details,
            hazardType : state.hazardType,
            hazardTypeExtra : state.hazardTypeExtra ,
            hazardState : HazardStatus.initial.name,
            embeding: embedingData??[]
        );
        
        final result = await _checkSimilarHazardCallable.call({'workplaceId':db.currentWorkplaceId,"embeding": embedingData});  
        if (result.data['similarityResult'] == 'similar') {
          _log.i('new hazard has similar one in database');  
          emit(state.copyWith(
            status: FormStatus.failure,
            errorMessage:
                'Error checking for similar hazards. Please try again later.'));
        return;
        } 
        hzId = await db.create<HseHazard>(newHazard)??'';
        if(hzId.isEmpty){
          emit(state.copyWith(status: FormStatus.failure));
          return;
        }
        for (HseTask tsk in state.tasksToAdd){
            final taskMap = tsk.toMap();
            taskMap[HseTaskFields.hseRequestId.name] = hzId;
            taskMap[HseTaskFields.hseRequestType.name] = TaskRequestType.hazard.name;
            taskMap[HseTaskFields.requesterId.name] = prefs.currentUserId;
            final newTaskId = await db.create<HseTask>(HseTask.fromMap(taskMap));
            if(newTaskId == null){
              emit(state.copyWith(status: FormStatus.failure));
              return;
            }
            await db.updateOne<HseHazard>(originalHazard!.id, {HseHazardFields.taskIds.name : FieldValue.arrayUnion([newTaskId]) } );
            if(prefs.isEnableNotifcations) await sendTaskNotification(tsk.responsibleId,tsk.details);
        }
        if( tempImageFile !=null ){
            await storage.uploadImage( 
              imageFile: tempImageFile!.readAsBytesSync(),
              photoPath: "${currentUser.currentWorkplace}/hazards/",
              photoName: hzId,
              onProgress: (progress){
                emit(state.copyWith(uploadProgress: progress));
              }
            ).whenComplete(() {
                tempImageFile = null;
              })
            .then((onValue) async {
              await db.updateOne<HseHazard>(hzId, {HseHazardFields.imgUrl.name: "${db.currentUser?.currentWorkplace}/hazards/$hzId"});
            });
        }
        if(currentWorkplaceSettings !=null) {
          final curWpSet = await db.findOne<UserWorkplace>(db.currentUser!.currentWorkplaceDataId!);
          final hazardPoints = currentWorkplaceSettings!.createHazardPoints;
          final curPoints = curWpSet?.points??0;
          final newPoints = curPoints + hazardPoints;
          await db.updateOne<UserWorkplace>(
            db.currentUser!.currentWorkplaceDataId!,
            {UserWorkPlaceFields.points.name: newPoints},
          );
        }
      }
      // editing hazard
      else{
       // 1. Create a map to track changes
      final updatedFields = <String, dynamic>{};

      // 2. Compare and add changed fields to the map
      if (state.location != originalHazard!.location) {
        updatedFields[HseHazardFields.location.name] = state.location;
      }
      if (state.locationExtra != originalHazard!.locationExtra) {
        updatedFields[HseHazardFields.locationExtra.name] = state.locationExtra;
      }
      if (state.details != originalHazard!.details) {
        updatedFields[HseHazardFields.details.name] = state.details;
      }
      if (state.hazardType != originalHazard!.hazardType) {
        updatedFields[HseHazardFields.hazardType.name] = state.hazardType;
      }
      if (state.hazardTypeExtra != originalHazard!.hazardTypeExtra) {
        updatedFields[HseHazardFields.hazardTypeExtra.name] = state.hazardTypeExtra;
      }
      if( state.imageFile !=null ){
            await storage.uploadImage( 
              imageFile: state.imageFile!.readAsBytesSync(),
              photoPath: "${currentUser.currentWorkplace}/hazards/",
              photoName: originalHazard!.id,
              onProgress: (progress){
                emit(state.copyWith(uploadProgress: progress));
              }
            ).whenComplete(() {
                tempImageFile = null;
              })
            .then((onValue) async {
              await db.updateOne<HseHazard>(originalHazard!.id, {HseHazardFields.imgUrl.name: "${db.currentUser?.currentWorkplace}/hazards/${originalHazard!.id}"});
            });
      }
      if(state.editingHazard && updatedFields.isNotEmpty) {
        await db.updateOne<HseHazard>(originalHazard!.id,updatedFields);
      }
        for (HseTask tsk in state.tasksToAdd){
          final taskMap = tsk.toMap();
          taskMap[HseTaskFields.hseRequestId.name] = originalHazard?.id;
          taskMap[HseTaskFields.hseRequestType.name] = TaskRequestType.hazard.name;
          taskMap[HseTaskFields.requesterId.name] = prefs.currentUserId;
          final newTaskId = await db.create<HseTask>(HseTask.fromMap(taskMap));
          if(newTaskId == null){
            emit(state.copyWith(status: FormStatus.failure));
            return;
          }
          await db.updateOne<HseHazard>(originalHazard!.id, {HseHazardFields.taskIds.name : FieldValue.arrayUnion([newTaskId]) } );
          if(prefs.isEnableNotifcations) await sendTaskNotification(tsk.responsibleId,tsk.details);
      }
      }
      
      hazardsToDelete.clear();      
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

  void mainTutorialFinished(){
    prefs.setFirstTimeHazardCreate(false);
  }
}