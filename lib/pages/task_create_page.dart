import 'dart:ui' show ImageFilter;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/widgets/form_DateTime.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../blocs/task_create_bloc.dart';
import '../enums/form_status.dart';
import '../models/auth_user.dart';
import '../repository/logging_reprository.dart' show LoggerReprository;
import '../widgets/form_button.dart';
import '../widgets/form_text_field.dart';

class TaskCreatePage extends StatelessWidget{
  TaskCreatePage({super.key,this.isManaged=false});
  final _log = LoggerReprository('TaskCreatePage'); 

  final bool isManaged;
  final _formKey = GlobalKey<FormState>();
  final _detailsKey = GlobalKey();
  final _responsibleKey = GlobalKey();
  final _hseRequestTypeKey = GlobalKey();
  final _dueDateKey = GlobalKey();
  final _saveButtonKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final TaskCreateCubit cubit = context.read<TaskCreateCubit>()..initForm();
    return Scaffold(
      appBar: AppBar(
                title: Text( 
                        'taskTitle'.tr(),
                        style: const TextStyle(
                              fontSize: 40, fontWeight: 
                              FontWeight.bold)
                        )
              ),
      body: Column(
        children: [
          BlocConsumer<TaskCreateCubit, TaskCreateFormUpdate>(
                bloc: cubit,
                listener: (BuildContext context, TaskCreateFormUpdate state) {
              if (state.status == FormStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:  Text(state.errorMessage==null? 'error'.tr():'error'.tr(args:  [state.errorMessage??""])),
                    ),
                  );
              }
              if (state.status == FormStatus.success) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('success'.tr()),
                    ),
                  );
                  context.pop(cubit.state);
              }
              if (cubit.prefs.firstTimeTaskCreate) {
                      _showTutorial(context);
                  }
            }, 
                builder: (BuildContext context, TaskCreateFormUpdate state) {
                  return Expanded(child: taskCreateForm(context));
                }
                ),
        ],
      )
          );
  }

  Widget taskCreateForm( BuildContext context) {
    final TaskCreateCubit cubit = context.read<TaskCreateCubit>();
    return Form(
              key: _formKey,
              autovalidateMode: cubit.state.autovalidateMode,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Column(
                          spacing: 8,
                          children: [
                            //details
                            FormTextField(
                              key: _detailsKey,
                              validator: cubit.validateDetailsIsNotEmpty,
                              onChanged: cubit.updateDetails,
                              keyboardType: TextInputType.name,
                              labelText: 'detailsLabel'.tr(),
                              hintText: "detailsMessage".tr(),
                            ),
                            ///responsible
                            DropdownMenu<AuthUser>(
                                key: _responsibleKey,
                                selectedTrailingIcon: const Icon(
                                  Icons.keyboard_arrow_up_sharp,
                                  size: 20
                                ),
                                inputDecorationTheme: InputDecorationTheme(
                                  filled: false,
                                  fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,//Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                      width: 0.6
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(1),
                                      width: 0.6
                                    ),
                                  )
                                ),
                                expandedInsets: EdgeInsets.zero,
                                label: Text('responsibleLabel'.tr()),
                                onSelected: (AuthUser? value) {
                                  // This is called when the user selects an item.
                                  if(value!=null){
                                    cubit.updateResponsibleId(value.email);
                                  } 
                                },
                                searchCallback: (List<DropdownMenuEntry<AuthUser?>> entries, String query) {
                                  return entries.indexWhere((e) => 
                                  (e.value!.firstName!=null && e.value!.firstName!.contains(query)) || 
                                  (e.value!.lastName!=null && e.value!.lastName!.contains(query)) || 
                                  (e.value!.displayName!=null && e.value!.displayName!.contains(query)) || 
                                  (e.value!.displayNameLocal!=null && e.value!.displayNameLocal!.contains(query))
                                  );
                                },
                                
                                dropdownMenuEntries: cubit.responsibles.map<DropdownMenuEntry<AuthUser>>((AuthUser usr) {
                                  return DropdownMenuEntry<AuthUser>(
                                  trailingIcon: const Icon(
                                    Icons.keyboard_arrow_down_sharp,
                                    size: 20,
                                  ),
                                  
                                  label: cubit.responsibles.first.firstName??'',
                                  labelWidget: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${usr.firstName} ${usr.lastName}'),
                                              Text(
                                                usr.email, 
                                                style: TextStyle(fontSize: 12, color: Colors.grey[600])
                                              )
                                            ],
                                          ),
                                  value: usr,);
                                  }).toList()
                            ),
                            ///hseRequestType
                            if(!isManaged)
                            DropdownMenu<String>(
                              key: _hseRequestTypeKey,
                              expandedInsets: EdgeInsets.zero,
                              label: Text('hseRequestTypeLabel'.tr()),                            
                              initialSelection:cubit.hseRequestTypeSelection.first,
                              onSelected: (String? value) {
                                // This is called when the user selects an item.
                                if(value!=null){
                                  cubit.updateHseRequestType(value);
                                } 
                              },
                              dropdownMenuEntries: cubit.hseRequestTypeSelection.map<DropdownMenuEntry<String>>((String value) {
                                return DropdownMenuEntry<String>(value: value, label: value);
                              }).toList(),
                            ),
                            // due date
                            FormDateTime(
                              fieldLabelText:cubit.state.dueDate.isAfter(DateTime.now()) ? 'dueDateLabel'.tr():cubit.state.dueDate.toIso8601String(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 10),
                              onDateSubmitted: (date) {
                                    cubit.updateDueDate(date);
                                  },
                              selectableDayPredicate: (day) => true, 
                            ),
                            
                            //Buttons
                            FormButton(
                              key: _saveButtonKey,
                              buttonText: 'ok'.tr(),
                              onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (isManaged) {
                                      if(context.mounted){
                                        context.pop(cubit.createManagedTask());
                                      }
                                    }else{
                                      await cubit.saveTask();
                                      if(context.mounted){
                                        context.pop();
                                      }
                                    }
                                  } else {
                                    // in case a user has submitted invalid form we'll set 
                                    // AutovalidateMode.always which will rebuild the form
                                    // in result we'll start getting error message
                                    cubit.updateAutovalidateMode(AutovalidateMode.always);
                                  }
                                }
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            );
  }

  // void _selectDate(BuildContext context) async {
  //   final TaskCreateCubit _cubit = context.read<TaskCreateCubit>();
  //   final _format = DateFormat.yMd();
  //   final DateTime? picked = await showDatePicker(
  //       context: context,
  //       initialDate: _cubit.state.dueDate,
  //       DateTime.parse(_cubit.state.dueDate):
  //       DateTime.now(),
  //       firstDate: DateTime(2000),
  //       lastDate: DateTime(2050),
  //     );
  //     //bool checkOldDue = _cubit.state.dueDate.isNotEmpty && picked != DateTime.parse(_cubit.state.dueDate);
  //     if (picked != null) {
  //         final dt = DateTime(picked.year, picked.month, picked.day);
  //         _cubit.updateDueDate(dt.toString());
  //     }
  // }

  void _showTutorial(BuildContext context) {
    final List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "detailsKey",
        keyTarget: _detailsKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "detailsTaskTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "detailsTaskTutorialMessage".tr(), 
                      style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    
    targets.add(
      TargetFocus(
        identify: "responsibleKey",
        keyTarget: _responsibleKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "responsibleTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "responsibleTutorialMessage".tr(), 
                      style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "hseRequestTypeKey",
        keyTarget: _hseRequestTypeKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "hseRequestTypeTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "hseRequestTypeTutorialMessage".tr(), 
                      style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "dueDateKey",
        keyTarget: _dueDateKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "dueDateTaskTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "dueDateTaskTutorialMessage".tr(), 
                      style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "saveButtonKey",
        keyTarget: _saveButtonKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "saveButtonTaskTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "saveButtonTaskTutorialMessage".tr(), 
                      style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );


    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.grey.shade600,
      textSkip: "skip".tr(),
      paddingFocus: 10,
      //opacityShadow: 0.8,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        //context.read<HomeCubit>().emit(context.read<HomeCubit>().state.copyWith(showTutorial: false));
        context.read<TaskCreateCubit>().mainTutorialFinished();
        _log.i('onFinish...');
      },
      onClickTarget: (target) {
        _log.i('onClickTarget: $target');
      },
      onClickOverlay: (target) {
        _log.i('onClickOverlay: $target');
      },
      onSkip: () {
        context.read<TaskCreateCubit>().mainTutorialFinished();
        _log.i('tutorial skipped');
        return true;
      },
    ).show(context: context);
  }

}

