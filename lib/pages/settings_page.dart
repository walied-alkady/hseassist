import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

import '../blocs/settings_bloc.dart';
import '../enums/app_page.dart';
import '../enums/user_role.dart';
import 'language_selection_dialog.dart';
import 'theme_selection_dialog.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('settingsTitle'.tr()),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: "generalSettingsTitle".tr()),
              // if(context.read<SettingsCubit>().db.isAdmin || context.read<SettingsCubit>().db.isCurrentUserMaster)
              // Tab(text: "kpisTitle".tr()),
              // if(context.read<SettingsCubit>().db.isAdmin || context.read<SettingsCubit>().db.isCurrentUserMaster)
              // Tab(text: "pointsTitle".tr()),
              // if(context.read<SettingsCubit>().db.isAdmin || context.read<SettingsCubit>().db.isCurrentUserMaster)
              // Tab(text: "workplaceSettingsTitle".tr()),
            ],
          ),
        ),
        body: FutureBuilder(
          future: context.read<SettingsCubit>().initSettings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return BlocBuilder<SettingsCubit, SettingsStates>(
                  builder: (context, state) {
                    final cubit = context.read<SettingsCubit>();
                    return TabBarView(
                          children: [
                            // Tab 1: General Settings
                            SafeArea(
                            child: SettingsList(
                                                sections: [
                                                  SettingsSection(
                                                    title: Text('generalSettingsTitle'.tr()),
                                                    tiles: [
                                                      //language
                                                      SettingsTile.navigation(
                                                        title: Text('languageTitle'.tr()),
                                                        leading: const Icon(Icons.language),
                                                        description: Text(state.language),
                                                        onPressed: (context) {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) => const LanguageSelectionDialog(),
                                                          );
                                                        },
                                                      ),
                                                      // themes
                                                      SettingsTile.navigation(
                                                            title: Text('themeLabel'.tr()),
                                                            leading: const Icon(Icons.color_lens),
                                                            onPressed:(context) {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) => const ThemeSelectionDialog(),
                                                          );
                                                        }
                                                            
                                                      ),
                                                      // dark mode
                                                      SettingsTile.switchTile(
                                                        title: Text('darkModeTitle'.tr()),
                                                        leading: const Icon(Icons.dark_mode),
                                                        onToggle: (bool value) {
                                                          cubit.settingUpdate(AppSetts.theme,value);
                                                        },
                                                        initialValue: state.isDarkmode,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                ),
                            // Tab  : targets
                            // if(context.read<SettingsCubit>().db.isAdmin || context.read<SettingsCubit>().db.isCurrentUserMaster)
                            // SafeArea(
                            //   child: SettingsList(
                            //                     sections: [
                            //                       SettingsSection(
                            //                         tiles: [
                            //                           // targetHazardIdsPerYear
                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('targetHazardIdsPerYearTitle'.tr()),
                            //                               subtitle: Text(state.targetHazardIdsPerYear.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.targetHazardIdsPerYear.toDouble(),
                            //                                   label: state.targetHazardIdsPerYear.round().toString(),
                            //                                   min: 0,
                            //                                   max: 100,
                            //                                   divisions: 20,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateTargetHazardIdsPerYear(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),
                            //                           // targetUncompletedTasksPerYear
                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('targetUncompletedTasksPerYearTitle'.tr()),
                            //                               subtitle: Text(state.targetUncompletedTasksPerYear.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.targetUncompletedTasksPerYear.toDouble(),
                            //                                   label: state.targetUncompletedTasksPerYear.round().toString(),
                            //                                   min: 0,
                            //                                   max: 100,
                            //                                   divisions: 20,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateTargetUncompletedTasksPerYear(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),
                            //                           // targetMiniSessionHrsPerYearPerUser
                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('targetMiniSessionHrsPerYearPerUserTitle'.tr()),
                            //                               subtitle: Text(state.targetMiniSessionHrsPerYearPerUser.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.targetMiniSessionHrsPerYearPerUser.toDouble(),
                            //                                   label: state.targetMiniSessionHrsPerYearPerUser.round().toString(),
                            //                                   min: 0,
                            //                                   max: 100,
                            //                                   divisions: 20,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateTargetMiniSessionHrsPerYearPerUser(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),

                            //                         ],
                            //                       ),
                            //                     ],
                            //                   ),
                            // ), 
                            // // Tab 2: workplace points
                            // if(context.read<SettingsCubit>().db.isAdmin || context.read<SettingsCubit>().db.isCurrentUserMaster)
                            // SafeArea(
                            //   child: SettingsList(
                            //                     sections: [
                            //                       SettingsSection(
                            //                         tiles: [
                            //                           // dark mode
                            //                           // First Use Points
                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('firstUsePointsTitle'.tr()),
                            //                               subtitle: Text(state.firstUsePoints.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.firstUsePoints.toDouble(),
                            //                                   label: state.firstUsePoints.round().toString(),
                            //                                   min: 0,
                            //                                   max: 100,
                            //                                   divisions: 20,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateFirstUsePoints(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),
                                                      
                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('createHazardPointsTitle'.tr()),
                            //                               subtitle: Text(state.createHazardPoints.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.createHazardPoints.toDouble(),
                            //                                   label: state.createHazardPoints.round().toString(),
                            //                                   min: 0,
                            //                                   max: 100,
                            //                                   divisions: 20,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateCreateHazardPoints(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),
                                                      
                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('createTaskPointsTitle'.tr()),
                            //                               subtitle: Text(state.createTaskPoints.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.createTaskPoints.toDouble(),
                            //                                   label: state.createTaskPoints.round().toString(),
                            //                                   min: 0,
                            //                                   max: 100,
                            //                                   divisions: 20,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateCreateTaskPoints(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),

                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('finishTaskPointsTitle'.tr()),
                            //                               subtitle: Text(state.finishTaskPoints.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.finishTaskPoints.toDouble(),
                            //                                   label: state.finishTaskPoints.round().toString(),
                            //                                   min: 0,
                            //                                   max: 100,
                            //                                   divisions: 20,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateFinishTaskPoints(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),

                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('createIncidentPointsTitle'.tr()),
                            //                               subtitle: Text(state.createIncidentPoints.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.createIncidentPoints.toDouble(),
                            //                                   label: state.createIncidentPoints.round().toString(),
                            //                                   min: 0,
                            //                                   max: 100,
                            //                                   divisions: 20,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateCreateIncidentPoints(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),
                                                    
                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('miniSessionPointsTitle'.tr()),
                            //                               subtitle: Text(state.miniSessionPoints.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.miniSessionPoints.toDouble(),
                            //                                   label: state.miniSessionPoints.round().toString(),
                            //                                   min: 0,
                            //                                   max: 100,
                            //                                   divisions: 20,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateMiniSessionPoints(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),

                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('quizeGameAnswerPointsTitle'.tr()),
                            //                               subtitle: Text(state.quizeGameAnswerPoints.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.quizeGameAnswerPoints.toDouble(),
                            //                                   label: state.quizeGameAnswerPoints.round().toString(),
                            //                                   min: 0,
                            //                                   max: 100,
                            //                                   divisions: 50,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateQuizeGameAnswerPoints(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),
                                                      
                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('quizeGameLevelPointsTitle'.tr()),
                            //                               subtitle: Text(state.quizeGameLevelPoints.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.quizeGameLevelPoints.toDouble(),
                            //                                   label: state.quizeGameLevelPoints.round().toString(),
                            //                                   min: 0,
                            //                                   max: 100,
                            //                                   divisions: 50,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateQuizeGameLevelPoints(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),

                            //                           CustomSettingsTile(
                            //                             child: ListTile(
                            //                               title: Text('appUsageDurationPointsTitle'.tr()),
                            //                               subtitle: Text(state.appUsageDurationPoints.toString() ),
                            //                               trailing: SizedBox(
                            //                                 width: 200,
                            //                                 child: Slider(
                            //                                   value: state.appUsageDurationPoints.toDouble(),
                            //                                   label: state.appUsageDurationPoints.round().toString(),
                            //                                   min: 0,
                            //                                   max: 50,
                            //                                   //divisions: 10,  // Optional: For discrete values
                            //                                   onChanged: (double value) {
                            //                                     context.read<SettingsCubit>().updateAppUsageDurationPoints(value.toInt());
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             )
                            //                             ),
                                                      
                            //                         ],
                            //                       ),
                            //                     ],
                            //                   ),
                            // ),      
                            // // Tab 3: location
                            // if(context.read<SettingsCubit>().db.isAdmin || context.read<SettingsCubit>().db.isCurrentUserMaster)
                            // SafeArea(
                            //   child: SettingsList(
                            //     sections: [
                            //       SettingsSection(
                            //         title: Text("locationText"),
                            //         tiles: [
                            //           SettingsTile.navigation(
                            //             title: Text('locationText'.tr()),
                            //             leading: const Icon(Icons.location_searching),
                            //             onPressed: (context) => context.goNamed(AppPage.workplaceLocation.path),
                            //           ),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),    
                          ],
                        );
                      }
            );
          }
        ),
      ),
    );
}


}