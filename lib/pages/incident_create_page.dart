import 'dart:ui' show ImageFilter;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/models/hse_task.dart';
import 'package:hseassist/pages/pages.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../blocs/incident_create_bloc.dart';
import '../enums/form_status.dart';
import '../models/workplace_location.dart';
import '../repository/logging_reprository.dart';
import '../widgets/form_button.dart';
import '../widgets/form_menue.dart';
import '../widgets/form_text_field.dart';

class IncidentCreatePage extends StatelessWidget{
  IncidentCreatePage({super.key});
  final _log = LoggerReprository('IncidentCreatePage'); 
  final _incidentFormKey = GlobalKey<FormState>();
  final _incidentDetailsKey = GlobalKey();
  final _incidentLocationKey = GlobalKey();
  final _incidentlocationExtraKey = GlobalKey();
  final _incidentTypeKey = GlobalKey();
  final _incidentTypeExtraKey = GlobalKey();
  final _incidentDamageOrInjuryKey = GlobalKey();
  final _incidentPreventionKey = GlobalKey();
  final _incidentTasksKey = GlobalKey();
  final _incidentSaveButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final IncidentCreateCubit cubit = context.read<IncidentCreateCubit>()..initForm();
    
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar( // Use SliverAppBar
              title:Text(cubit.originalIncident == null? "newIncidentTitle".tr() : "editIncidentTitle".tr(),
                        style: 
                          const TextStyle(
                              fontSize: 40, fontWeight: 
                              FontWeight.bold)
                        ),
              pinned: true, // Keep app bar visible
              expandedHeight: 300.0, // Initial height of the expanded app bar
              flexibleSpace: FlexibleSpaceBar(
                background: Center(
                  child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Badge(
                                offset: Offset(-30, 30),
                                label: Text('ad'.tr(), style: Theme.of(context).textTheme.bodySmall),
                                child: (cubit.state.uploadProgress != null || cubit.state.uploadProgress == 0)?
                                    CircularProgressIndicator.adaptive(value: cubit.state.uploadProgress)
                                    : 
                                    CircleAvatar(
                                      backgroundColor: Colors.grey[50],
                                      radius: 100,
                                      child: GestureDetector(
                                        onTap: () async => await cubit.updatePhoto(context),
                                        child: 
                                        cubit.state.imageFile!=null 
                                            ? CircleAvatar( // Use a nested CircleAvatar for preview
                                                radius: 100,
                                                backgroundImage: FileImage(cubit.state.imageFile!), // Display from File
                                            )
                                            : Icon(
                                                Icons.warning, 
                                                size: 100,
                                                color: Colors.grey[400],
                                              ),
                                      ),
                                    ),
                              ),
                                Visibility(
                                  visible: context.read<IncidentCreateCubit>().state.markForDelete,
                                  child: Positioned.fill(  // Cover the entire page
                                          child: Container(
                                            color: Colors.black54, 
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 200,
                                                    height: 200,
                                                    child: Icon(Icons.close, size: 150, color: Colors.red,), // Or use Image.asset or CustomPainter
                                                  ),])
                                            ),  
                                            )

                                          )
                                )
                              ],
                            ),
                          ),
                  // ... (rest of your FlexibleSpaceBar content)
                ),
              ),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              BlocConsumer<IncidentCreateCubit, IncidentCreateFormUpdate>(
                    bloc: cubit,
                    listener: (BuildContext context, IncidentCreateFormUpdate state) {
                  if (state.status == FormStatus.failure) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage==null? 'error'.tr():'error'.tr(args:  [state.errorMessage??""])),
                        ),
                      );
                  }
                  if (state.status == FormStatus.success) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('successSnackbarMessage'.tr()),
                        ),
                      );
                      context.pop();
                  }
                  if (cubit.prefs.firstTimeIncidentCreate) {
                      _showTutorial(context);
                  }
                  // if (state.status == FormStatus.imagePreview) {
                  //   _showImagePreviewModal(context); // Show modal when image is picked
                  // }
                }, 
                    builder: (BuildContext context, IncidentCreateFormUpdate state) {
                      return incidentReportForm(context);
                    }
                    ),
            ],
          ),
        ),
      )
          );
  }

  Widget incidentReportForm( BuildContext context) {
    final cubit = context.read<IncidentCreateCubit>();
    return Form(
              key: _incidentFormKey,
              autovalidateMode: cubit.state.autovalidateMode,
              child: Expanded(
                child: SingleChildScrollView(
                  child: Column(
                        spacing: 10,
                        children: [
                          Stack(
                            children: [Column(
                              spacing: 10,
                              children: [
                                //details
                                FormTextField(
                                  key: _incidentDetailsKey,
                                  initialValue: cubit.originalIncident?.details,
                                  labelText: 'detailsLabel'.tr(),
                                  hintText: "enterIncidentDetailsHint".tr(),
                                  validator: cubit.validateDetailsIsNotEmpty,
                                  onChanged: cubit.updateDetails,
                                  keyboardType: TextInputType.text,
                                  enabled: (context.read<IncidentCreateCubit>().state.isEnabled) & !cubit.state.status.isInProgress,
                                ),
                                ///location
                                FormMenue<WorkplaceLocation>(
                                  key: _incidentLocationKey,
                                  initialValue: cubit.state.selectedlocation,
                                  onSaved: (newValue) => cubit.updateLocation(newValue),
                                  validator: (value) {
                                    if (value?.isEmpty??true) {
                                      return 'locationRequiredMessage'.tr();
                                    }
                                    return null;
                                  },
                                  enabled: context.read<IncidentCreateCubit>().state.isEnabled & !cubit.state.status.isInProgress,
                                  label: Text('locationText'.tr()),
                                  onSelectedCallback: (value) => cubit.updateLocation(value),
                                  searchCallback: (entries, query) {
                                                return entries.indexWhere((e) => 
                                                (
                                                  e.value.description.contains(query)) 
                                                );
                                              },
                                  dropdownMenuEntries: cubit.workplaceLocations.map<DropdownMenuEntry<WorkplaceLocation>>((WorkplaceLocation value) {
                                                return DropdownMenuEntry<WorkplaceLocation>(value: value, label: value.description);
                                              }).toList(),
                                ),
                                //location extra
                                FormTextField(
                                  key: _incidentlocationExtraKey,
                                  initialValue: cubit.originalIncident?.locationExtra,
                                  labelText: "locationDetailsLabel".tr(),
                                  hintText: 'locationDetailsMessage'.tr(),
                                  validator: cubit.validateDetailsIsNotEmpty,
                                  onChanged: cubit.updateLocationExtra,
                                  keyboardType: TextInputType.text,
                                  enabled: context.read<IncidentCreateCubit>().state.isEnabled & !cubit.state.status.isInProgress,
                                ),
                                ///incidentType
                                FormMenue<String>(
                                  key: _incidentTypeKey,
                                  initialValue: cubit.state.incidentType,
                                  onSaved: (newValue) => cubit.updateIncidentType(newValue),
                                  validator: (value) {
                                    if (value?.isEmpty??true) {
                                      return 'IncidentTypeRequiredMessage'.tr();
                                    }
                                    return null;
                                  },
                                  enabled: context.read<IncidentCreateCubit>().state.isEnabled & !cubit.state.status.isInProgress,
                                  label: Text("incidentTypeLabel".tr()),
                                  onSelectedCallback: (value) => cubit.updateIncidentType(value),
                                  dropdownMenuEntries: cubit.incidentTypeSelection.map<DropdownMenuEntry<String>>((String value) {
                                                return DropdownMenuEntry<String>(value: value, label: value);
                                              }).toList(),
                                ),
                                ///incidentTypeEXTRA
                                FormTextField(
                                  key: _incidentTypeExtraKey,
                                  initialValue: cubit.originalIncident?.incidentTypeExtra,
                                  labelText:  "incidentTypeExtraLabel".tr(),
                                  hintText: 'enterIncidentTypeExtraHint'.tr(),
                                  validator: cubit.validateDetailsIsNotEmpty,
                                  onChanged: cubit.updateIncidentTypeExtra,
                                  keyboardType: TextInputType.text,
                                  enabled: context.read<IncidentCreateCubit>().state.isEnabled & !cubit.state.status.isInProgress,
                                ),
                                ///damageOrInjury
                                FormMenue<String>(
                                  key: _incidentDamageOrInjuryKey,
                                  initialValue: cubit.state.damageOrInjury,
                                  onSaved: (newValue) => cubit.updateDamageOrInjury(newValue),
                                  validator: (value) {
                                    if (value?.isEmpty??true) {
                                      return 'IncidentDamageRequiredMessage'.tr();
                                    }
                                    return null;
                                  },
                                  enabled: context.read<IncidentCreateCubit>().state.isEnabled & !cubit.state.status.isInProgress,
                                  label: Text("incidentDamageInjuryLabel".tr()),
                                  onSelectedCallback: (value) => cubit.updateDamageOrInjury(value),
                                  dropdownMenuEntries: cubit.damageOrInjuryTypeSelection.map<DropdownMenuEntry<String>>((String value) {
                                                return DropdownMenuEntry<String>(value: value, label: value);
                                              }).toList(),
                                ),
                                //preventionReccomendations
                                FormTextField(
                                  key: _incidentPreventionKey,
                                  initialValue: cubit.originalIncident?.preventionReccomendations,
                                  labelText: "preventionReccomendationsLabel".tr(),
                                  hintText: 'preventionReccomendationsMessage'.tr(),
                                  validator: cubit.validateDetailsIsNotEmpty,
                                  onChanged: cubit.updatePreventionReccomendations,
                                  keyboardType: TextInputType.text,
                                  enabled: context.read<IncidentCreateCubit>().state.isEnabled & !cubit.state.status.isInProgress,
                                ),
                                // save 
                                const Divider(),
                                // Task List
                                ListView.builder(
                                    key: _incidentTasksKey,
                                    shrinkWrap: true,  // Important for ListView inside a Column
                                    itemCount: context.read<IncidentCreateCubit>().state.tasks.length,
                                    itemBuilder: (context, index) {
                                      final task = context.read<IncidentCreateCubit>().state.tasks[index];
                                      return ListTile(
                                        title: Text(task.details),
                                        // ... display other task details ...
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => context.read<IncidentCreateCubit>().removeTask(index),
                                        ),
                                      );
                                    },
                                  ),
                                // Add Task Button
                                //if(!context.read<IncidentCreateCubit>().state.isReadonly)
                                ElevatedButton(
                                    key: _incidentSaveButtonKey,
                                    onPressed: cubit.state.status.isInProgress?null: () async {
                                      // Logic to add a new task.  For example, show a dialog:
                                    await   _showAddTaskScreen(context);
                                    },
                                    child: Text("addTaskButton".tr()),
                                  ),
                                const Divider(),
                              ]
                            ),
                            Visibility(
                            visible: cubit.state.markForDelete,
                            child: Positioned.fill(  // Cover the entire page
                                    child: Container(
                                      color: Colors.black54, 
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              height: 200,
                                              child: Icon(Icons.close, size: 150, color: Colors.red,), // Or use Image.asset or CustomPainter
                                            ),])
                                      ),  
                                      )

                                    )
                          )
                        ]),
                        //delete
                        Column(
                          spacing: 10,
                          children: [
                            FormButton(
                            buttonText: 'ok'.tr(),
                            onPressed: cubit.state.status.isInProgress?null: () async {
                                if (_incidentFormKey.currentState!.validate()) {
                                  await cubit.saveIncident();
                                } else {
                                  // in case a user has submitted invalid form we'll set 
                                  // AutovalidateMode.always which will rebuild the form
                                  // in result we'll start getting error message
                                  cubit.updateAutovalidateMode(AutovalidateMode.always);
                                }
                              }
                          ),
                            if(cubit.originalIncident?.id != null && 
                            cubit.state.isEnabled && 
                            cubit.state.isAdmin)
                            Center(
                              child: SwitchListTile(
                                title: Text('delete'.tr()),
                                value: cubit.state.markForDelete,
                                onChanged: (bool value) {
                                  cubit.markForDeletion(value);
                                },
                                                        ),
                            ),
                        
                          ]
                        ),
                        ],
                      ),
                ),
              ),
            );
  }
  
  Future<void> _showAddTaskScreen(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final IncidentCreateCubit cubit = context.read<IncidentCreateCubit>();
    IncidentCreateFormUpdate? savedIncidentFormState  = cubit.state;
    //final result = await context.pushNamed<HseTask>(AppPage.taskCreateHazard.name,extra:true);
    
    final result = await showModalBottomSheet<HseTask>(
    context: context,
    isScrollControlled: false, // Allow resizing based on content
    builder: (context) {
      return Localizations.override( // EasyLocalization override still needed
        context: context,
        locale: context.locale,
        child: BlocProvider.value( // Provide the cubit
          value: cubit.taskCubit,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom), // Handle keyboard
            child: TaskCreatePage(isManaged: true,),  // Your task creation content
          ),
        ),
      );
    },
  );
    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!context.mounted) return;

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    cubit
      ..updateAutovalidateMode(savedIncidentFormState.autovalidateMode)
      ..updateDetails(savedIncidentFormState.details)
      ..updateLocationExtra(savedIncidentFormState.locationExtra)
      ..updateLocation(savedIncidentFormState.selectedlocation) 
      ..updateIncidentType(savedIncidentFormState.incidentType)
      ..updateIncidentTypeExtra(savedIncidentFormState.incidentTypeExtra)
      ;

      savedIncidentFormState = null; // Clear saved state to free memory
    if(result != null){
      cubit.addTask(result);
    }
  }

    
  void _showTutorial(BuildContext context) {
    final List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "detailsKey",
        keyTarget: _incidentDetailsKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "detailsIncidentTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "detailsIncidentTutorialMessage".tr(), 
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
        identify: "locationKey",
        keyTarget: _incidentLocationKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "locationIncidentTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "locationIncidentTutorialMessage".tr(), 
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
        identify: "locationExtraKey",
        keyTarget: _incidentlocationExtraKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "locationExtraIncidentTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "locationExtraIncidentTutorialMessage".tr(), 
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
        identify: "incidentTypeKey",
        keyTarget: _incidentTypeKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "incidentTypeTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "incidentTypeTutorialMessage".tr(), 
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
        identify: "incidentTypeExtraKey",
        keyTarget: _incidentTypeExtraKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "incidentTypeExtraTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "incidentTypeExtraTutorialMessage".tr(), 
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
        identify: "damageOrInjury",
        keyTarget: _incidentDamageOrInjuryKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "incidentdamageOrInjuryTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "incidentdamageOrInjuryTutorialMessage".tr(), 
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
        identify: "prevention",
        keyTarget: _incidentPreventionKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "incidentPreventionTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "incidentPreventionTutorialMessage".tr(), 
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
        identify: "tasksKey",
        keyTarget: _incidentTasksKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "tasksIncidentTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "tasksIncidentTutorialMessage".tr(), 
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
        keyTarget: _incidentSaveButtonKey,
        shape: ShapeLightFocus.RRect, 
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "saveButtonIncidentTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "saveButtonIncidentTutorialMessage".tr(), 
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
        context.read<IncidentCreateCubit>().mainTutorialFinished();
        _log.i('onFinish...');
      },
      onClickTarget: (target) {
        _log.i('onClickTarget: $target');
      },
      onClickOverlay: (target) {
        _log.i('onClickOverlay: $target');
      },
      onSkip: () {
        context.read<IncidentCreateCubit>().mainTutorialFinished();
        _log.i('tutorial skipped');
        return true;
      },
    ).show(context: context);
  }

}

