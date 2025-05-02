import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../enums/form_status.dart';
import '../models/workplace_location.dart';
import '../repository/logging_reprository.dart';
import '../service/authentication_service.dart';
import '../service/database_service.dart';
import 'manager.dart';

class WorkplaceLocationState extends Equatable{
  
  final List<WorkplaceLocation> locations;
  final String addText;
  final int modifyIndex;
  final String modifyValue;

  final String? editMessage;
  final String? errorMessage;
  final FormStatus status;

  const WorkplaceLocationState({
    this.locations = const [],
    this.addText='',
    this.modifyIndex=-1,
    this.modifyValue='',
    this.editMessage,
    this.errorMessage,
    this.status = FormStatus.initial,
});
  
  @override
  List<Object?> get props => [locations.length,locations,addText,errorMessage,modifyIndex,modifyValue,FormStatus,editMessage];
  WorkplaceLocationState copyWith({
    List<WorkplaceLocation>? locations,
    String? addText,
    int? modifyIndex,
    String? modifyValue,
    String? editMessage,
    String? errorMessage,
    FormStatus? status,

  }) {
    return WorkplaceLocationState(
      locations: locations ?? this.locations,
      addText: addText ?? this.addText,
      modifyIndex: modifyIndex ?? this.modifyIndex,
      modifyValue: modifyValue ?? this.modifyValue,
      editMessage: editMessage ?? this.editMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }
}

class WorkplaceLocationCubit extends Cubit<WorkplaceLocationState> with Manager<WorkplaceLocationCubit>{
  
  WorkplaceLocationCubit(
    {
      required AuthenticationService  authService,
      required DatabaseService  db,
      required LoggerReprository  log,
    }
  ) : super(const WorkplaceLocationState());
  final List<WorkplaceLocation> _locations = [];
  final _log = LoggerReprository('WorkplaceLocationCubit');
  
  Future<void> initForm() async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try{
      _log.i('loading ...');
      _log.i('updateing lists...');
      await loadLists();
      emit(state.copyWith(locations: List.from(_locations)));
      _log.i('Done...');
    }catch(e){
      _log.i('Loading error...');
      emit(state.copyWith(errorMessage: e.toString()));
    }finally{
      emit(state.copyWith(status: FormStatus.initial,errorMessage: null));
    }
  }
  
  Future<void> loadLists() async{
    await Future.wait<void>([
      db.findAll<WorkplaceLocation>().then((result) {
        _locations.clear();
        _log.i('got ${result.length} locations data...');  
        return _locations.addAll(result);
        }),  
    ]).catchError(
        (error) {
        _log.e('Error: $error');
        emit(state.copyWith(errorMessage: error.toString()));
        
        return error;
      }
    );
  }
  
  Future<void> addLocation() async {
    emit(state.copyWith(status: FormStatus.inProgress));
    final alreadyExists =_locations.any((element) => element.description.trim() == state.addText);

    if(state.addText==''){
      emit(state.copyWith(editMessage: 'errorMessages.empty'.tr()));
     // log.i("state.message: ${state.errorMessage}");
      return;
    }else if(alreadyExists){
      emit(state.copyWith(editMessage: 'errorMessages.alreadyExists'.tr()));
      //log.i("state.message: ${state.errorMessage}");
      return;
    }
    else{      
      final newLocation = WorkplaceLocation(id:'' ,description: state.addText); 
      try {
        
        await db.create<WorkplaceLocation>(newLocation);
        _locations.add(WorkplaceLocation(id:'' ,description:  state.addText));
        emit(state.copyWith(locations: List.from(_locations))); // Or a success state
      } catch (e) {
        emit(state.copyWith(status: FormStatus.failure, errorMessage: 'Error adding location: $e'));
      }finally{
        emit(state.copyWith(status: FormStatus.initial,errorMessage: null));
      }
    }
  }

  void removeLocation(int index)async{
    emit(state.copyWith(status: FormStatus.inProgress));
    try{
      await db.deleteOne<WorkplaceLocation>(_locations[index].id);
      _locations.removeAt(index);
      emit(state.copyWith(locations: List.from(_locations)));
    }catch (e) {
        emit(state.copyWith(status: FormStatus.failure, errorMessage: 'Error removing location: $e'));
    }finally{
      emit(state.copyWith(status: FormStatus.initial,errorMessage: null));
    }
  }

  void renameLocation(int index,String value){
    // final w = WorkplaceLocation(description: value);
    // _locations[index] = w; 
    //emit(state.copyWith(locations: List.from(_locations)));
    emit(state.copyWith(modifyIndex: index,modifyValue: value));
  }
  
  void renameLocationSubmit() async{
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      final w = WorkplaceLocation(id:'',description: state.modifyValue);
      await db.updateOne<WorkplaceLocation>( _locations[state.modifyIndex].id, {WorkplaceLocationFields.description.name: state.modifyValue})  ;
      _locations[state.modifyIndex] = w; 
      emit(state.copyWith(locations: List.from(_locations)));
    } on Exception catch (e) {
        emit(state.copyWith(status: FormStatus.failure, errorMessage: 'Error renaming location: $e'));

    }finally{
      emit(state.copyWith(status: FormStatus.initial,errorMessage: null));
    }
  }
  
  void addLocationTextChaned(String description){
    emit(state.copyWith(addText: description));
    if(description.trim().isNotEmpty){
      emit(state.copyWith(editMessage: null));
    }
  }
  
}
