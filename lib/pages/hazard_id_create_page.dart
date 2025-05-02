import 'dart:ui' show ImageFilter;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/models/hse_task.dart';
import 'package:hseassist/pages/pages.dart';
import 'package:hseassist/utilities/extension_methods.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../blocs/hazard_id_create_bloc.dart';
import '../enums/form_status.dart';
import '../models/workplace_location.dart';
import '../repository/logging_reprository.dart';
import '../widgets/form_button.dart';
import '../widgets/form_menue.dart';
import '../widgets/form_text_field.dart';

class HazardIdCreatePage extends StatelessWidget{
  HazardIdCreatePage({super.key});
  final _log = LoggerReprository('HazardIdCreatePage'); 
  final _formKey = GlobalKey<FormState>();
  final _detailsKey = GlobalKey();
  final _locationKey = GlobalKey();
  final _locationExtraKey = GlobalKey();
  final _hazrdTypeKey = GlobalKey();
  final _hazrdTypeExtraKey = GlobalKey();
  final _tasksKey = GlobalKey();
  final _saveButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    
    final HazardIdCreateCubit cubit = context.read<HazardIdCreateCubit>()..initForm();
    
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: NestedScrollView(
        physics: const ClampingScrollPhysics() ,
        
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar( // Use SliverAppBar
              title:Text( 
                  cubit.originalHazard == null? "newHazardTitle".tr(): "editHazardTitle".tr(),
                  style: const TextStyle(
                          fontSize: 40, 
                          fontWeight: FontWeight.bold)
                    ),
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
                                child: (context.read<HazardIdCreateCubit>().state.uploadProgress != null || context.read<HazardIdCreateCubit>().state.uploadProgress == 0)?
                                    CircularProgressIndicator.adaptive(value: context.read<HazardIdCreateCubit>().state.uploadProgress)
                                    :
                                    CircleAvatar(
                                      backgroundColor: Colors.grey[50],
                                      radius: 100,
                                      child:  GestureDetector(
                                        onTap: () async => await cubit.updatePhoto(context),
                                        child: 
                                        context.read<HazardIdCreateCubit>().state.imageFile!=null 
                                            ? CircleAvatar( // Use a nested CircleAvatar for preview
                                                radius: 100,
                                                backgroundImage: FileImage(context.read<HazardIdCreateCubit>().state.imageFile!), // Display from File
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
                                  visible: context.read<HazardIdCreateCubit>().state.markForDelete,
                                  child: Positioned.fill(  // Cover the entire page
                                          child: Container(
                                            color: Colors.black54, 
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 200,
                                                    height: 150,
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
          child: BlocConsumer<HazardIdCreateCubit, HazardIdCreateFormUpdate>(
                    bloc: cubit,
                    listener: (BuildContext context, HazardIdCreateFormUpdate state) {
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
                      if (cubit.prefs.firstTimeHazardCreate) {
                          _showTutorial(context);
                      }
                      // if (state.status == FormStatus.imagePreview) {
                      //   _showImagePreviewModal(context); // Show modal when image is picked
                      // }
                    }, 
                    builder: (BuildContext context, HazardIdCreateFormUpdate state) {
                      return hazardIdForm(context);
                    }
          ),
        ),
      ),
      //bottomNavigationBar: _buildPhotoPreviewList(context),
          );
  }

  Widget hazardIdForm( BuildContext context) {
    final cubit = context.read<HazardIdCreateCubit>();
    return Form(
              key: _formKey,
              autovalidateMode: cubit.state.autovalidateMode,
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
                                    key: _detailsKey,
                                    initialValue: cubit.originalHazard?.details,
                                    labelText: 'detailsLabel'.tr(),
                                    hintText: "enterHazardDetailsHint".tr(),
                                    validator: cubit.validateDetailsIsNotEmpty,
                                    onChanged: cubit.updateDetails,
                                    keyboardType: TextInputType.text,
                                    enabled: (context.read<HazardIdCreateCubit>().state.isEnabled) & !cubit.state.status.isInProgress,
                                  ),
                                  ///location
                                  FormMenue<WorkplaceLocation>(
                                    key: _locationKey,
                                    initialValue: cubit.state.selectedlocation,
                                    onSaved: (newValue) => cubit.updateLocation(newValue),
                                    validator: (value) {
                                      if (value?.isEmpty??true) {
                                        return 'Required Field';
                                      }
                                      return null;
                                    },
                                    enabled: context.read<HazardIdCreateCubit>().state.isEnabled & !cubit.state.status.isInProgress,
                                    label: Text("locationText".tr()),
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
                                    key: _locationExtraKey,
                                    initialValue: cubit.originalHazard?.locationExtra,
                                    labelText: "locationDetailsText".tr(),
                                    hintText: 'locationDetailsHint'.tr(),
                                    validator: cubit.validateDetailsIsNotEmpty,
                                    onChanged: cubit.updateLocationExtra,
                                    keyboardType: TextInputType.text,
                                    enabled: context.read<HazardIdCreateCubit>().state.isEnabled & !cubit.state.status.isInProgress,
                                  ),
                                  ///hazrdType
                                  FormMenue<String>(
                                    key: _hazrdTypeKey,
                                    initialValue: cubit.state.hazardType,
                                    onSaved: (newValue) => cubit.updateHazardType(newValue),
                                    validator: (value) {
                                      if (value?.isEmpty??true) {
                                        return 'hazardTypeRequiredMessage'.tr();
                                      }
                                      return null;
                                    },
                                    enabled: context.read<HazardIdCreateCubit>().state.isEnabled & !cubit.state.status.isInProgress,
                                    label: Text("hazardTypeLabel".tr()),
                                    onSelectedCallback: (value) => cubit.updateHazardType(value),
                                    dropdownMenuEntries: cubit.hazardTypeSelection.map<DropdownMenuEntry<String>>((String value) {
                                                  return DropdownMenuEntry<String>(value: value, label: value);
                                                }).toList(),
                                  ),
                                  ///hazrdTypeEXTRA
                                  FormTextField(
                                    key: _hazrdTypeExtraKey,
                                    initialValue: cubit.originalHazard?.hazardTypeExtra,
                                    labelText:  "hazardTypeExtraLabel".tr(),
                                    hintText: "enterHazardTypeExtraHint".tr(),
                                    validator: cubit.validateDetailsIsNotEmpty,
                                    onChanged: cubit.updateHazardTypeExtra,
                                    keyboardType: TextInputType.text,
                                    enabled: context.read<HazardIdCreateCubit>().state.isEnabled & !cubit.state.status.isInProgress,
                                  ),
                                  //Take photo 
                                  // cubit.showAds?
                                  // Badge(
                                  //   offset: Offset(-30, 18),
                                  //   label: Text('ad'.tr(), style: Theme.of(context).textTheme.bodySmall),
                                  //   child: FormButton(
                                  //             buttonText: 'photo'.tr(),
                                  //             onPressed: cubit.state.status.isInProgress?null: 
                                  //               () async {
                                  //                 await context.read<HazardIdCreateCubit>().pickImage();
                                  //                 }, // Call renamed function
                                  //           )
                                  // ):
                                  // FormButton(
                                  //   buttonText: 'photo'.tr(),
                                  //   onPressed: cubit.state.status.isInProgress?null: 
                                  //     () async => await context.read<HazardIdCreateCubit>().pickImage(), // Call renamed function
                                  // ),
                                  // if (cubit.state.imageFile != null)
                                  // Image.file(cubit.state.imageFile!),
                                  // save 
                                  const Divider(),
                                  // Task List
                                  ListView.builder(
                                      key: _tasksKey,
                                      shrinkWrap: true,  // Important for ListView inside a Column
                                      physics: const NeverScrollableScrollPhysics(), // Important! Prevent scrolling in ListView.builder
                                      itemCount: context.read<HazardIdCreateCubit>().state.tasks.length,
                                      itemBuilder: (context, index) {
                                        final task = context.read<HazardIdCreateCubit>().state.tasks[index];
                                        return ListTile(
                                          title: Text(task.details),
                                          // ... display other task details ...
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => context.read<HazardIdCreateCubit>().removeTask(index),
                                          ),
                                        );
                                      },
                                    ),
                                  // Add Task Button
                                  //if(!context.read<HazardIdCreateCubit>().state.isReadonly)
                                  ElevatedButton(
                                      key: _saveButtonKey,
                                      onPressed: cubit.state.status.isInProgress && !(_formKey.currentState?.validate()??false)
                                      ?null: () async {
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
                                  if (_formKey.currentState!.validate() || cubit.state.markForDelete) {
                                    await cubit.saveHazard();
                                  } else {
                                    // in case a user has submitted invalid form we'll set 
                                    // AutovalidateMode.always which will rebuild the form
                                    // in result we'll start getting error message
                                    cubit.updateAutovalidateMode(AutovalidateMode.always);
                                  }
                                }
                            ),
                              if((cubit.originalHazard?.id != null &&  cubit.state.isEnabled) || cubit.state.isAdmin)
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
            );
  }

  Widget _buildPhotoPreviewList(BuildContext context) {
    final cubit = context.read<HazardIdCreateCubit>();
    // Check if there are any image files in the state
    if (cubit.state.imageFile == null) {
        return const SizedBox.shrink(); // Don't show the list if there are no images
    }

    return Container(
      height: 100, // Adjust as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 1, //only one image for now
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                cubit.updateExpandable(cubit.state.imageFile);
              },
              child: Image.file(
                cubit.state.imageFile!,
                width: 80, // Adjust as needed
                height: 80, // Adjust as needed
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
}

  Future<void> _showAddTaskScreen(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final HazardIdCreateCubit cubit = context.read<HazardIdCreateCubit>();
    HazardIdCreateFormUpdate? savedHazardFormState  = cubit.state;
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
      ..updateAutovalidateMode(savedHazardFormState.autovalidateMode)
      ..updateDetails(savedHazardFormState.details)
      ..updateLocationExtra(savedHazardFormState.locationExtra)
      ..updateLocation(savedHazardFormState.selectedlocation) 
      ..updateHazardType(savedHazardFormState.hazardType)
      ..updateHazardTypeExtra(savedHazardFormState.hazardTypeExtra);

      savedHazardFormState = null; // Clear saved state to free memory
    if(result != null){
      cubit.addTask(result);
    }
  }
  
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
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "detailsTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "detailsTutorialMessage".tr(), 
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
        keyTarget: _locationKey,
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
                    "locationTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "locationTutorialMessage".tr(), 
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
        keyTarget: _locationExtraKey,
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
                    "locationExtraTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "locationExtraTutorialMessage".tr(), 
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
        identify: "hazrdTypeKey",
        keyTarget: _hazrdTypeKey,
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
                    "hazrdTypeTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "hazrdTypeTutorialMessage".tr(), 
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
        identify: "hazrdTypeExtraKey",
        keyTarget: _hazrdTypeExtraKey,
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
                    "hazrdTypeExtraTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "hazrdTypeExtraTutorialMessage".tr(), 
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
        keyTarget: _tasksKey,
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
                    "tasksHazardTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "tasksHazardTutorialMessage".tr(), 
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
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "saveButtonHazardTutorialTitle".tr(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "saveButtonHazardTutorialMessage".tr(), 
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
        context.read<HazardIdCreateCubit>().mainTutorialFinished();
        _log.i('onFinish...');
      },
      onClickTarget: (target) {
        _log.i('onClickTarget: $target');
      },
      onClickOverlay: (target) {
        _log.i('onClickOverlay: $target');
      },
      onSkip: () {
        context.read<HazardIdCreateCubit>().mainTutorialFinished();
        _log.i('tutorial skipped');
        return true;
      },
    ).show(context: context);
  }

}

