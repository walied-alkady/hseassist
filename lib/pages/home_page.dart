import 'dart:ui' show ImageFilter;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hseassist/models/models.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../blocs/home_bloc.dart';
import '../enums/app_page.dart';
import '../enums/chat_type.dart';
import '../repository/logging_reprository.dart';
import '../widgets/floating_action_menu.dart';
import 'chat_page.dart';
import 'list_page.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/shimmer_loading.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final GlobalKey _addHazardButtonKey = GlobalKey();
  final GlobalKey _addIncidentButtonKey = GlobalKey();
  final GlobalKey _addTaskButtonKey = GlobalKey();
  final GlobalKey _addHazardIncidentTaskButtonKey = GlobalKey();
  final GlobalKey _summeryCardKey = GlobalKey();
  final GlobalKey _homePageIconKey = GlobalKey();
  final GlobalKey _dashPageIconKey = GlobalKey();
  final GlobalKey _chatPageIconKey = GlobalKey();
  final _log = LoggerReprository('HomePage');

  final test = true;
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>()..initForm();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<HomeCubit>().startTutorial();
    // });
    return test
        ? BlocConsumer<HomeCubit, HomePageState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, state) {
              return Scaffold(
                  body: Column(
                    children: [
                      Column(
                        children: [
                          _buildCalendarView(context, state.tasks,cubit),
                          Card(
                            elevation: 4.0,
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildIconWithText(
                                    context,
                                    Icons.warning,
                                    'addHazardTitle'.tr(),
                                    AppPage.hazardIdCreate,
                                  ),
                                  _buildIconWithText(
                                    context,
                                    Icons.error,
                                    'addIncidentTitle'.tr(),
                                    AppPage.incidentCreate,
                                  ),
                                  _buildIconWithText(
                                    context,
                                    Icons.task,
                                    'addTaskTitle'.tr(),
                                    AppPage.taskCreate,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                      Offstage(
                          offstage: state.bannerAd == null,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: state.bannerAd != null
                                ? SizedBox(
                                    width: state.bannerAd?.size.width.toDouble(),
                                    height: state.bannerAd?.size.height.toDouble(),
                                    child: AdWidget(ad: state.bannerAd!),
                                  )
                                : const SizedBox.shrink(),
                          )
                      )
              ]));
            },
          )
        : FutureBuilder(
            future: context.read<HomeCubit>().initForm(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return BlocBuilder<HomeCubit, HomePageState>(
                  builder: (context, state) {
                    return Scaffold(
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: ShimmerLoading(
                              loadingString: state
                                  .loadingString, // The structure of the widget you're loading
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Column(
                  children: [
                    Center(child: Text('${"error".tr()}: ${snapshot.error}')),
                  ],
                ); // Handle errors
              } else {
                return BlocConsumer<HomeCubit, HomePageState>(
                    bloc: cubit,
                    listener: (context, state) {
                      if (cubit.prefs.firstTimeHome &&
                          state.bottomNavIndex == 0) {
                        _showTutorial(context);
                      }
                    },
                    builder: (context, state) {
                      return Scaffold(
                        key: _key,
                        appBar: AppBar(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    height: 40,
                                    width: 40,
                                  ),
                                ),
                                Flexible(
                                  // Or Expanded
                                  child: Center(
                                    child: Text(
                                      "${cubit.db.currentUser?.firstName} ${cubit.db.currentUser?.lastName} @ ${cubit.currentWorkplaceName}",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                if (state.logoUrl?.isNotEmpty ?? false)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Image.network(
                                      cubit.state.logoUrl!,
                                      height: 40,
                                      width: 40,
                                    ),
                                  ),
                              ],
                            ),
                            actions: [
                              PopupMenuButton<String>(
                                onSelected: (String value) async {
                                  switch (value) {
                                    case 'Profile':
                                      {
                                        context.goNamed(AppPage.profile.name);
                                      }
                                      break;

                                    case 'Setting':
                                      {
                                        context.goNamed(AppPage.settings.name);
                                      }
                                    case 'admin':
                                      {
                                        context.goNamed(AppPage.admin.name);
                                      }
                                    case 'game':
                                      {
                                        context.goNamed(
                                            AppPage.hazardHunterGame.name);
                                      }

                                    case 'gameQuize':
                                      {
                                        context.goNamed(AppPage.quizeGame.name);
                                      }
                                      break;
                                    case 'Logout':
                                      {
                                        cubit.signOut(context);
                                      }
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    value: 'Profile',
                                    enabled: !state.loadingData,
                                    child: Text('profile'.tr()),
                                  ),
                                  if (cubit.db.isCurrentUserMaster)
                                    PopupMenuItem(
                                      value: 'gameQuize',
                                      enabled: !state.loadingData,
                                      child: Text('gameQuize'.tr()),
                                    ),
                                  if (cubit.db.isCurrentUserMaster)
                                    PopupMenuItem(
                                      value: 'game',
                                      enabled: !state.loadingData,
                                      child: Text('hazardHunterGame'.tr()),
                                    ),
                                  if (cubit.db.isAdmin ||
                                      cubit.db.isCurrentUserMaster)
                                    PopupMenuItem(
                                      value: 'admin',
                                      enabled: !state.loadingData,
                                      child: Text('admin'.tr()),
                                    ),
                                  PopupMenuItem(
                                    value: 'Setting',
                                    enabled: !state.loadingData,
                                    child: Text('settings'.tr()),
                                  ),
                                  PopupMenuItem(
                                    value: 'Logout',
                                    enabled: !state.loadingData,
                                    child: Text('logout'.tr()),
                                  ),
                                ],
                              ),
                            ]),
                        // endDrawer: Container(
                        //   alignment: AlignmentDirectional.centerEnd,
                        //   constraints: const BoxConstraints(maxWidth: 400),
                        //   child: const HomeDrawerPage(),
                        // ),
                        bottomNavigationBar: NavigationBar(
                          destinations: <Widget>[
                            NavigationDestination(
                              key: _homePageIconKey,
                              icon: Icon(Icons.home),
                              label: 'home'.tr(),
                            ),
                            NavigationDestination(
                              key: _dashPageIconKey,
                              icon: Icon(Icons.dashboard),
                              label: 'dash'.tr(),
                            ),
                            NavigationDestination(
                              key: _chatPageIconKey,
                              icon: Icon(Icons.chat),
                              label: 'chat'.tr(),
                            ),
                          ],
                          onDestinationSelected: cubit.updateBottomNavIndex,
                          indicatorColor: Colors.blue[400],
                          selectedIndex: state.bottomNavIndex,
                        ),
                        floatingActionButton: state.bottomNavIndex == 0
                            ? FloatingActionMenu(
                                mainButtonKey: _addHazardIncidentTaskButtonKey,
                                buttons: [
                                  FloatingActionButton(
                                    key: _addHazardButtonKey,
                                    tooltip: 'addHazardTitle'.tr(),
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    onPressed: () => context
                                        .goNamed(AppPage.hazardIdCreate.name),
                                    child: const Icon(Icons.warning),
                                  ),
                                  FloatingActionButton(
                                    key: _addIncidentButtonKey,
                                    tooltip: 'addIncidentTitle'.tr(),
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    onPressed: () => context
                                        .goNamed(AppPage.incidentCreate.name),
                                    child: const Icon(Icons.error),
                                  ),
                                  FloatingActionButton(
                                    key: _addTaskButtonKey,
                                    tooltip: 'addTaskTitle'.tr(),
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    onPressed: () => context
                                        .goNamed(AppPage.taskCreate.name),
                                    child: const Icon(Icons.task),
                                  ),
                                ],
                                onMainButtonPressed: cubit
                                        .prefs.firstTimeHomeFab
                                    ? () {
                                        Future.delayed(
                                            const Duration(milliseconds: 500),
                                            () {
                                          if (context.mounted) {
                                            _showFabTutorial(context);
                                          }
                                        });
                                      }
                                    : null,
                              )
                            : null,
                        // floatingActionButton: FloatingActionButton(
                        //   foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        //   backgroundColor: Theme.of(context).colorScheme.secondary,
                        //   onPressed: () {
                        //     // final scaffold = _key.currentState;
                        //     // if (scaffold != null) {
                        //     //   if (scaffold.isEndDrawerOpen) {
                        //     //     scaffold.closeEndDrawer();
                        //     //     cubit.closeDrawer();
                        //     //   } else {
                        //     //     scaffold.openEndDrawer();
                        //     //     cubit.updateChatCach();
                        //     //   }
                        //     // }
                        //   },
                        //   child: const Icon(Icons.add),
                        // ),
                        body: <Widget>[
                          /// Home page
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                //rating bar
                                _createRatingBar(state.overallRating),
                                if (state.overallRating == 5)
                                  Text(
                                    'welDoneMessage'.tr(),
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                //Display a banner when ready
                                Offstage(
                                    offstage: state.bannerAd == null,
                                    child: _createBanner(state.bannerAd)),
                                //summery cards
                                _createSummery(context,
                                    points: state.points,
                                    pointsRating: state.pointsRating,
                                    tasks: state.tasksDueNo,
                                    tasksRating: state.tasksRating,
                                    incidents: state.incidents.length,
                                    incidentsRating: state.incidentsRating,
                                    hazards: state.hazards.length,
                                    hazardsRating: state.hazardsRating,
                                    miniSessions: cubit.db.currentUser
                                            ?.assignedMiniSessions?.length ??
                                        0),
                                if (state.hasManagedlocation)
                                  _createManagedLocationSummeryCard(context,
                                      locationsData: context
                                          .read<HomeCubit>()
                                          .locationsData),
                              ],
                            ),
                          ),
                          //dash
                          SingleChildScrollView(
                              child: Column(children: [
                            FutureBuilder(
                                future: Future.wait([
                                  cubit
                                      .updateHazardChartData(), // Pass location
                                  cubit.updateIncidentChartData(),
                                  cubit.updateTasksChartData(), // Pass location
                                ]),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    final chartDataList =
                                        snapshot.data as List; // Cast to List

                                    final hazardChartData = chartDataList[0]
                                        as List<BarChartGroupData>;
                                    final incidentChartData = chartDataList[2]
                                        as List<BarChartGroupData>;
                                    final taskChartData = chartDataList[1]
                                        as List<BarChartGroupData>;

                                    if (hazardChartData.isNotEmpty ||
                                        taskChartData.isNotEmpty ||
                                        incidentChartData.isNotEmpty) {
                                      // Check if both have data
                                      return Column(
                                        children: [
                                          if (incidentChartData.isNotEmpty)
                                            ChartContainer(
                                              title: 'incidentsTitle'.tr(),
                                              color: Colors.grey.shade300,
                                              chart: BarChartContent(
                                                  incidentChartData),
                                            ),
                                          const SizedBox(height: 30),
                                          if (hazardChartData.isNotEmpty)
                                            ChartContainer(
                                              title: 'hazardsTitle'.tr(),
                                              color: Colors.grey.shade300,
                                              chart: BarChartContent(
                                                  hazardChartData),
                                            ),
                                          const SizedBox(height: 30),
                                          if (taskChartData.isNotEmpty)
                                            ChartContainer(
                                              title: 'tasksTitle'.tr(),
                                              color: Colors.grey.shade300,
                                              chart: BarChartContent(
                                                  taskChartData),
                                            )
                                        ],
                                      );
                                    } else {
                                      return Text("noDataMssage".tr());
                                    }
                                  } else if (snapshot.hasError) {
                                    return Text('error'
                                        .tr(args: [snapshot.error.toString()]));
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                }),
                          ])),
                          // community chat
                          _buildChatSelection(context)
                        ][cubit.state.bottomNavIndex],
                      );
                    });
              }
            });
  }

  Widget _buildIconWithText(
      BuildContext context, IconData icon, String text, AppPage page) {
    return InkWell(
      onTap: () {
        context.goNamed(page.name);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center,),
        ],
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, List<HseTask> tasks,HomeCubit cubit) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month - 3, now.day);
    final lastDay = DateTime(now.year, now.month + 3, now.day);
    final selectedDay = DateTime.now();
    final focusedDay = DateTime.now();
    final events = _getEventsForDay(selectedDay, tasks);
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('tasksCalendarTitle'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TableCalendar<HseTask>(
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: focusedDay,
              calendarFormat: CalendarFormat.week,
              eventLoader: (day) {
                return _getEventsForDay(day, tasks);
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 16,
                        height: 16,
                        child: Center(
                          child: Text(
                            '${events.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                // Handle day selection
                cubit.updateSelectedDay(selectedDay);
              },
              onPageChanged: (focusedDay) {
                // Handle page change
                cubit.updateFocusedDay(focusedDay);
              },
            ),
            const SizedBox(height: 10),
            Text('tasksForSelectedDay'.tr(args: [DateFormat('dd-MM-yyyy').format(selectedDay)])),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final task = events[index];
                return ListTile(
                  title: Text(task.hseRequestType),
                  subtitle: Text(task.details),
                  onTap: () {
                    // Handle task tap
                    context.goNamed(AppPage.taskCreate.name,extra: task);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<HseTask> _getEventsForDay(DateTime day, List<HseTask> tasks) {
    List<HseTask> events = [];
    for (var task in tasks) {
      if (task.dueDate != null && isSameDay(task.dueDate!, day)) {
        events.add(task);
      }
    }
    return events;
  }


  void _showTutorial(BuildContext context) {
    final List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "addHazardIncidentTaskButtonKey",
        keyTarget: _addHazardIncidentTaskButtonKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomLeft,
        paddingFocus: 60,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "addHazardIncidentTaskButtonTutorialTitle"
                        .tr(), // keep the same title
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "addHazardIncidentTaskButtonTutorialMessage"
                          .tr(), // keep the same msg
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
        identify: "summeryCard",
        keyTarget: _summeryCardKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(bottom: 10),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "summeryCardTitle".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "summeryCardMessage".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
        identify: "dashPageIcon",
        keyTarget: _dashPageIconKey,
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
                    "dashPageIconTitle".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "dashPageIconMessage".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
        identify: "chatPageIcon",
        keyTarget: _chatPageIconKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomLeft,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "chatPageIconTitle".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "chatPageIconMessage".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
        context.read<HomeCubit>().mainTutorialFinished();
        _log.i('onFinish...');
      },
      onClickTarget: (target) {
        _log.i('onClickTarget: $target');
      },
      onClickOverlay: (target) {
        _log.i('onClickOverlay: $target');
      },
      onSkip: () {
        context.read<HomeCubit>().mainTutorialFinished();
        _log.i('tutorial skipped');
        return true;
      },
    ).show(context: context);
  }

  void _showFabTutorial(BuildContext context) {
    final List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "addHazardButtonKey",
        keyTarget: _addHazardButtonKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "addHazardButtonTutorialTitle".tr(), // keep the same title
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "addHazardButtonTutorialMessage"
                          .tr(), // keep the same msg
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
        identify: "addIncidentButtonKey",
        keyTarget: _addIncidentButtonKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(bottom: 10),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "addIncidentButtonTutorialTitle".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "addIncidentButtonTutorialMessage".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
        identify: "addTaskButtonKey",
        keyTarget: _addTaskButtonKey,
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
                    "addTaskButtonTutorialTitle".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "addTaskButtonTutorialMessage".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
      //opacityShadow: 0.8,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        context.read<HomeCubit>().fabTutorialFinished();
        _log.i('onFinish...');
      },
      onClickTarget: (target) {
        _log.i('onClickTarget: $target');
      },
      onClickOverlay: (target) {
        _log.i('onClickOverlay: $target');
      },
      onSkip: () {
        context.read<HomeCubit>().fabTutorialFinished();
        _log.i('tutorial skipped');
        return true;
      },
    ).show(context: context);
  }

  Widget _createRatingBar(double initialRating, {double itemSize = 50.0}) {
    return RatingBarIndicator(
        rating: initialRating,
        itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
        itemCount: 5,
        itemSize: itemSize,
        direction: Axis.horizontal);
    //   return Center(child: RatingBar.builder(
    //                   ignoreGestures: true,
    //                   allowHalfRating : true,
    //                   initialRating: initialRating,
    //                   itemCount: 5,
    //                   itemBuilder: (context, index) {
    //                     switch (index) {
    //                         case 0:
    //                           return const Icon(
    //                               Icons.sentiment_very_dissatisfied,
    //                               color: Colors.red,
    //                           );
    //                         case 1:
    //                           return const Icon(
    //                               Icons.sentiment_dissatisfied,
    //                               color: Colors.redAccent,
    //                           );
    //                         case 2:
    //                           return const Icon(
    //                               Icons.sentiment_neutral,
    //                               color: Colors.amber,
    //                           );
    //                         case 3:
    //                           return const Icon(
    //                               Icons.sentiment_satisfied,
    //                               color: Colors.lightGreen,
    //                           );
    //                         case 4:
    //                             return const Icon(
    //                               Icons.sentiment_very_satisfied,
    //                               color: Colors.green,
    //                             );
    //                         default:
    //                           return const Icon(
    //                               Icons.sentiment_very_dissatisfied,
    //                               color: Colors.red,
    //                           );
    //                     }
    //                   },
    //                   onRatingUpdate: (rating) {
    //                     log.i(rating);
    //                   },
    //                   ),
    //                 );
  }

  Widget _createBanner(BannerAd? add) {
    return Align(
      alignment: Alignment.topCenter,
      child: add != null
          ? SizedBox(
              width: add.size.width.toDouble(),
              height: add.size.height.toDouble(),
              child: AdWidget(ad: add),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _createSummery(BuildContext context,
      {int points = 0,
      double? pointsRating,
      int tasks = 0,
      double? tasksRating,
      int incidents = 0,
      double? incidentsRating,
      int hazards = 0,
      double? hazardsRating,
      int miniSessions = 0}) {
    final cubit = context.read<HomeCubit>();
    return Card(
      key: _summeryCardKey,
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the start
            children: [
              Text('summeryTitle'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              ListTile(
                contentPadding: EdgeInsets.zero, // Remove ListTile padding
                title: Text('pointsTitle'.tr()),
                subtitle: Text('${points} '),
                leading: const Icon(Icons.account_box),
                trailing: pointsRating != null
                    ? _createRatingBar(pointsRating, itemSize: 25)
                    : null,
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero, // Remove ListTile padding
                title: Text('tasksTitle'.tr()),
                subtitle: Text(
                    "tasksDueReportedMessage".tr(args: [tasks.toString()])),
                leading: const Icon(Icons.task),
                trailing: tasksRating != null
                    ? _createRatingBar(tasksRating, itemSize: 25)
                    : null,
                // trailing: SizedBox(
                //   width: 150,
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       //view tasks
                //       TextButton(
                //             onPressed:  (){
                //       List<TaskItem> tasksList =[];
                //       cubit.state.tasks.forEach( (task)=>
                //         tasksList.add(
                //           TaskItem(
                //             id: task.id,
                //             title: task.hseRequestType,
                //             description: task.details,
                //             dueDate: task.dueDate.isEmpty?DateTime(9999):DateTime .parse(task.dueDate),
                //             status: task.status
                //           )
                //         )
                //       );
                //       context.goNamed(AppPage.list.name,extra: {"list":tasksList,"type":ItemType.task});
                //     },
                //             child: Text('view'.tr()),
                //           ),
                //       // new task
                //       TextButton(
                //         child: Text('add'.tr()),
                //         onPressed: () => context.goNamed(AppPage.taskCreate.name),
                //       )
                //   ],),
                // ),
                onTap: tasks == 0
                    ? null
                    : () {
                        List<TaskItem> tasksList = [];
                        cubit.state.tasks.forEach((task) => tasksList.add(
                            TaskItem(
                                id: task.id,
                                title: task.hseRequestType,
                                description: task.details,
                                dueDate: task.dueDate == null
                                    ? DateTime.now()
                                    : task.dueDate!,
                                status: task.status)));
                        context.goNamed(AppPage.list.name,
                            extra: {"list": tasksList, "type": ItemType.task});
                      },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero, // Remove ListTile padding
                title: Text('incidentsTitle'.tr()),
                subtitle: Text('incidentsReportedMessage'
                    .tr(args: [incidents.toString()])),
                leading: const Icon(Icons.error),
                trailing: incidentsRating != null
                    ? _createRatingBar(incidentsRating, itemSize: 25)
                    : null,
                // trailing: SizedBox(
                //   width: 150,
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       TextButton(
                //             onPressed:  (){
                //       List<IncidentItem> incidentsList =[];
                //       cubit.state.incidents.forEach( (incident) {
                //         if(incident.createdById == _authService.currentDbUser.id) {
                //           incidentsList.add(
                //           IncidentItem(
                //             id: incident.id,
                //             title: incident.damageOrInjury,
                //             description: incident.details,
                //             date: incident.createdAt.isEmpty?DateTime(9999):DateTime .parse(incident.createdAt)
                //           )
                //         );
                //         }

                //       });
                //       context.goNamed(AppPage.list.name,extra:{"list":incidentsList,"type":ItemType.incident});
                //     },
                //             child: Text('view'.tr()),
                //           ),
                //     TextButton(
                //         child: Text('add'.tr()),
                //         onPressed: () => context.goNamed(AppPage.taskCreateIncident.name),
                //       )
                //   ],),
                // ),
                onTap: incidents == 0
                    ? null
                    : () {
                        List<IncidentItem> incidentsList = [];
                        cubit.state.incidents.forEach((incident) {
                          if (incident.createdById ==
                              cubit.prefs.currentUserId) {
                            incidentsList.add(IncidentItem(
                                id: incident.id,
                                title: incident.damageOrInjury,
                                description: incident.details,
                                date: incident.createdAt!));
                          }
                        });
                        context.goNamed(AppPage.list.name, extra: {
                          "list": incidentsList,
                          "type": ItemType.incident
                        });
                      },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('hazardsTitle'.tr()),
                subtitle: Text(
                    'hazardsReportedMessage'.tr(args: [hazards.toString()])),
                leading: const Icon(Icons.warning),
                trailing: hazardsRating != null
                    ? _createRatingBar(hazardsRating, itemSize: 25)
                    : null,
                onTap: hazards == 0
                    ? null
                    : () {
                        List<HazardItem> hazardsList = [];
                        cubit.state.hazards.forEach((hazard) {
                          if (hazard.createdById == cubit.prefs.currentUserId) {
                            hazardsList.add(HazardItem(
                                id: hazard.id,
                                title: hazard.hazardType,
                                description: hazard.details,
                                location: hazard.location));
                          }
                        });
                        context.goNamed(AppPage.list.name, extra: {
                          "list": hazardsList,
                          "type": ItemType.hazard
                        });
                      },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('miniSessionTitle'.tr()),
                subtitle: Text('miniSessionReportMessage'
                    .tr(args: [miniSessions.toString()])),
                leading: const Icon(Icons.co_present),
                onTap: miniSessions == 0
                    ? null
                    : () {
                        context.goNamed(AppPage.miniSession.name);
                      },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _createManagedLocationSummeryCard(
    BuildContext context, {
    List<Map<String, dynamic>>? locationsData,
  }) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the start
            children: [
              Text('locationSummery'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              ListView.builder(
                shrinkWrap: true,
                itemCount: locationsData?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${locationsData?[index]['location']}'),
                    subtitle: Text(
                      '${'tasksTitle'.tr()}:${locationsData?[index]['tasks']} '
                      '${'incidentsTitle'.tr()}:${locationsData?[index]['incidents']} '
                      '${'hazardsTitle'.tr()}:${locationsData?[index]['hazards']} ',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatSelection(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return BlocBuilder<HomeCubit, HomePageState>(
      builder: (context, state) {
        if (state.loadingUsers) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return _buildChatList(context, cubit, state);
        }
      },
    );
  }

  Widget _buildChatList(
      BuildContext context, HomeCubit cubit, HomePageState state) {
    final cubit = context.read<HomeCubit>();
    return Column(
      children: [
        _buildChatTile(
            context, 'hseAssistChatTitle'.tr(), ChatType.ai, 'ai_chat_id'),
        Expanded(
          child: ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              final chatId =
                  cubit.getChatId(cubit.prefs.currentUserId, user.id);
              return _buildChatTile(context, user.displayName ?? 'unknown'.tr(),
                  ChatType.user, chatId,
                  user: user);
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.groups.length,
            itemBuilder: (context, index) {
              final group = state.groups[index];
              return _buildChatTile(
                  context, group.name, ChatType.group, group.id,
                  group: group);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatTile(
      BuildContext context, String title, ChatType chatType, String chatId,
      {AuthUser? user, ChatGroup? group}) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(title),
        onTap: () {
          _showChatBottomSheet(context, chatType, chatId,
              user: user, group: group);
        },
      ),
    );
  }

  void _showChatBottomSheet(
      BuildContext context, ChatType chatType, String chatId,
      {AuthUser? user, ChatGroup? group}) {
    final cubit = context.read<HomeCubit>();
    cubit.fetchChatHistory(
        chatId, chatType); // Fetch history before showing the sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) => ChatPage(
            chatId: chatId,
            chatType: chatType,
            scrollController: controller,
            user: user, // Pass the user if it's a user chat
            group: group, // Pass the group if it's a group chat,
          ),
        ),
      ),
    );
  }
}

class ChartContainer extends StatelessWidget {
  final Color color;
  final String title;
  final Widget chart;

  const ChartContainer({
    super.key,
    required this.title,
    required this.color,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.width * 0.95 * 0.65,
        padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(top: 10),
              child: chart,
            ))
          ],
        ),
      ),
    );
  }
}

class BarChartContent extends StatelessWidget {
  final List<BarChartGroupData>? data;
  const BarChartContent(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: data,
        borderData: FlBorderData(
            border: const Border(bottom: BorderSide(), left: BorderSide())),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
                axisNameWidget: Icon(Icons.numbers),
                sideTitles: SideTitles(reservedSize: 44, showTitles: true)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(reservedSize: 30, showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(reservedSize: 44, showTitles: false)),
            bottomTitles: AxisTitles(
                axisNameWidget: const Icon(Icons.calendar_month),
                sideTitles: SideTitles(
                  reservedSize: 30, showTitles: true,
                  // getTitlesWidget: (double value, TitleMeta meta){
                  //     String newVal= value.toString();
                  //     switch (value.toInt()) {
                  //       case 1:
                  //         newVal =  'Jan';
                  //         break;
                  //       case 2:
                  //         newVal =  'Feb';
                  //         break;
                  //       case 3:
                  //         newVal =  'Mar';
                  //         break;
                  //       case 4:
                  //         newVal =  'Apr';
                  //         break;
                  //       case 5:
                  //         newVal =  'May';
                  //         break;
                  //       case 6:
                  //         newVal =  'Jun';
                  //         break;
                  //       case 7:
                  //         newVal =  'Jul';
                  //         break;
                  //       case 8:
                  //         newVal =  'Aug';
                  //         break;
                  //       case 9:
                  //         newVal =  'Sep';
                  //         break;
                  //       case 10:
                  //         newVal =  'Oct';
                  //         break;
                  //       case 11:
                  //         newVal =  'Nov';
                  //         break;
                  //       case 12:
                  //         newVal =  'Dec';

                  //     }
                  //   return SideTitleWidget(
                  //     meta: TitleMeta (
                  //       axisSide: meta.axisSide,
                  //       min: 1,
                  //       max: 12,

                  //       ),
                  //     //axisSide: meta.axisSide,
                  //     child: Text(newVal));
                  // }
                ))),
      ),
    );
  }
}
