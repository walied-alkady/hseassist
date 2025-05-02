import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/enums/app_page.dart';
import 'package:hseassist/models/hse_task.dart';

import '../Exceptions/database_exception.dart';
import '../enums/form_status.dart';
import '../enums/task_status.dart';
import '../models/hse_hazard.dart';
import '../models/hse_incident.dart';
import '../pages/list_page.dart';
import '../repository/logging_reprository.dart';
import 'manager.dart';

class ListUpdate extends Equatable{
  const ListUpdate({
    
    this.autovalidateMode = AutovalidateMode.disabled, 
    this.errorMessage,
    this.status = FormStatus.initial,
    this. items=const [],
    this.selectedIndex=0,
    this.selections=const [false,false],
    this.scrollController
  });

  final AutovalidateMode autovalidateMode;
  final FormStatus status;
  final String? errorMessage;
  final List<ListItem> items;
  final int selectedIndex;
  final List<bool> selections;
  final ScrollController? scrollController;

  @override
  List<Object?> get props => [
        autovalidateMode,
        status,
        errorMessage,
        items,
        selectedIndex,
        selections,
        scrollController,
      ];

  ListUpdate copyWith({
    AutovalidateMode? autovalidateMode,
    FormStatus? status,
    bool? isValid,
    String? errorMessage,
    List<ListItem>? items,
    int? selectedIndex,
    List<bool>? selections,
    ScrollController? scrollController,
  }) {
    return ListUpdate(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,      
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      items: items ?? this.items,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selections: selections ?? this.selections,
      scrollController: scrollController ?? this.scrollController,      
    );
  }
}

class ListCubit extends Cubit<ListUpdate> with Manager<ListCubit>{

  HseTask? task;
  HseHazard? risk;
  HseIncident? incident;
  final List<ListItem> items;
  final ItemType itemType;
  final _log = LoggerReprository('ListCubit');

  ListCubit(this.items,this.itemType) : super(const ListUpdate());

  Future<void> initForm() async {
    emit(state.copyWith(
      items: items
    ));
  }
  
  Future<void> taskFeedback(String id,String feedbackText) async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      final Map<String,dynamic> taskUpdate = {
            HseTaskFields.status.name : TaskStatus.done.name,
            HseTaskFields.feedback.name : feedbackText,
      };
      await db.updateOne<HseTask>(id,taskUpdate);
      final tasksUpdate = state.items;
      tasksUpdate.removeWhere((item) => item.id == id);
      emit(state.copyWith(
        items:tasksUpdate,
        status: FormStatus.success));
      
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
  
  void viewHazard(BuildContext context,String id) async{
    _log.i('loading hazard data');
    final hazard =await db.findOne<HseHazard>(id);
    if(hazard !=null){
      if(context.mounted){
          context.goNamed(AppPage.hazardIdCreate.name,extra: {"editableHazard":hazard});
        }
    }
  }
  
  void updateFilterSelect(int index){
    if(index==0){

      emit(state.copyWith(selections: [true,false]));
    }else{
      emit(state.copyWith(selections: [false,true]));
    }
    emit(state.copyWith(selectedIndex: index));
  }

}
