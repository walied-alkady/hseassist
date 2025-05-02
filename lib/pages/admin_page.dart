import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/widgets/form_text_field.dart';
import 'package:icons_plus/icons_plus.dart';
import '../blocs/admin_bloc.dart';
import '../enums/app_page.dart';
import '../enums/form_status.dart';
import '../models/models.dart';
import '../repository/logging_reprository.dart';
import '../service/authentication_service.dart';

class AdminPage extends StatelessWidget {
  AdminPage({super.key});
  final _log = LoggerReprository('AdminPage');
  @override
  Widget build(BuildContext context) {
    bool loading=false;
    final cubit = context.read<AdminCubit>();
    return FutureBuilder(
      future: cubit.initData(),
      builder: (context,snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }
          return BlocBuilder<AdminCubit, UpdateAdminData>(
        builder: (BuildContext context, UpdateAdminData state) {
          return DefaultTabController(
            length: 5,
            initialIndex: state.tabIndex,
            child: Scaffold(
              appBar: AppBar(
                title: Text('admin'.tr()),
                bottom: TabBar(
                  //isScrollable: true,
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(
                      //icon: Icon(Icons.dashboard),
                      text: "dashboardTitle".tr(),
                    ),
                    Tab(
                      text: "usersTitle".tr(),
                      //icon: Icon(Icons.person_search),
                    ),
                    Tab(
                      text: "kpisTitle".tr(),
                      //icon: Icon(FontAwesome.kip_sign_solid),
                    ),
                    Tab(
                      text: "pointsTitle".tr(),
                      //icon: Icon(Icons.card_giftcard),
                    ),
                    Tab(
                      text: "locationTitle".tr(),
                      //icon: Icon(Icons.location_on),
                    )
                  ],
                  
                ),
                actions: [
                          PopupMenuButton<String>(
                            onSelected: (String value) async {
                              switch (value) {
                                case 'inviteUser':{
                                  context.goNamed(AppPage.inviteUser.name);
                                }
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: 'inviteUser',
                                enabled: !loading,
                                child: Text('inviteUser'.tr()),
                              ),
                            ],
                          )
                ]
              ),
              body: Builder(
                builder: (context) {
                  // Find the TabController within the build method
                  final tabController = DefaultTabController.of(context);
                  // Add the listener within the build method
                  tabController.addListener(() {
                    // Get the new index from the BLoC's state
                    final newIndex = DefaultTabController.of(context).index;
                    // Update the BLoC's state with the new index
                    context.read<AdminCubit>().updateTabIndex(newIndex);
                    // Update the TabController's index
                    tabController.animateTo(newIndex);
                  });
                  return TabBarView(
                    controller: tabController,
                    children: [
                      _getDash(context),
                      Center(child: UsersListAdminPage()),
                      _buildKpisTab(context),
                      _buildPointsTab(context),
                      _buildLocationTab(context)
                    ],            
                    
                  );
                }
              ),
              floatingActionButton: _getFAB(context, state.tabIndex),

            ),
            
          );
        }
    );
    }
    );
  }
  
  Widget? _getFAB(BuildContext context, int index) {
    final authUser = GetIt.instance<AuthenticationService>();
    final newLocationAddController = TextEditingController();
    final cubit = context.read<AdminCubit>();
    if (index == 4) {
      return FloatingActionButton(
        onPressed: () {
            showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('add'.tr()),
                          content: TextField(
                            controller: newLocationAddController,
                            decoration: InputDecoration(hintText: "newLocationString".tr()),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('cancel'.tr()),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text('ok'.tr()),
                              onPressed: () async {
                                _log.i(newLocationAddController.text);
                                await cubit.addLocation(newLocationAddController.text);
                                if(context.mounted) Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
        },
        child: const Icon(Icons.add_location),
      );
    }if (index == 1) {
      return FloatingActionButton(
        onPressed: ()=> context.goNamed(AppPage.inviteUser.name),
        child: const Icon(Icons.person_add),
      );
    } else {
      return null; // Hide the FAB when not in selection mode
    }
}
  
  Widget _getDash(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    final userPointsData = cubit.getUserPointsData();
    return Container(
              color: const Color(0xfff0f0f0),
              child: ListView(
                padding: const EdgeInsets.all(20),
                
                children: <Widget>[
                  if(userPointsData.isNotEmpty)
                  _buildChartContainer(
                    context,
                    title: 'User Points',
                    chart: _buildBarChart(userPointsData),
                  ),
                  if(cubit.hseHazards.isNotEmpty)
                  _buildChartContainer(
                    context,
                    title: 'Hazard Reports per Month',
                    chart: _buildHazardBarChart(cubit.hseHazards),
                  ),
                  if(cubit.hseHazards.isNotEmpty)
                  _buildChartContainer(
                    context,
                    title: 'Hazard per location',
                    chart: _buildHazardsInLocationBarChart(cubit.hseHazards),
                  ),
                  if(cubit.hseIncidents.isNotEmpty)
                  _buildChartContainer(
                    context,
                    title: 'Incident Reports per Month',
                    chart: _buildIncidentBarChart(cubit.hseIncidents),
                  ),
                  if(cubit.hseTasks.isNotEmpty)
                  _buildChartContainer(
                    context,
                    title: 'Completed Actions',
                    chart: _buildCompletedTasksBarChart(cubit.hseTasks),
                  ),
                  if(cubit.hseTasks.isNotEmpty)
                  _buildChartContainer(
                    context,
                    title: 'Pending Actions',
                    chart: _buildPendingTasksBarChart(cubit.hseTasks),
                  ),
                ],
              ),
            );
  }

  // Widget _buildChartContainer({required String title, required Widget chart}) {
  //   return Card(
  //     elevation: 2,
  //     margin: const EdgeInsets.only(bottom: 20),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             title,
  //             style: const TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const SizedBox(height: 10),
  //           chart,
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildChartContainer(BuildContext context, {required String title, required Widget chart}) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.width * 0.95 * 0.65,
        padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey, width: 1)
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

  Widget _buildBarChart(List<ChartData> data) {
    return BarChart(
      BarChartData(
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final chartData = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: chartData.y.toDouble(),
                width: 20, // Adjust bar width as needed
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
           show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return SideTitleWidget(
                    meta: meta,
                    space: 4, // Adjust spacing as needed
                    child: Text(data[index].x),
                  );
                  }
                  return const Text('');
                },
              reservedSize: 30,
              ),
            ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true,reservedSize: 25 ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
  
  //for hazards
  Widget _buildHazardBarChart(List<HseHazard> hazards) {
  // 1. Group Hazards by Month
  final hazardsByMonth = <String, int>{};
  for (final hazard in hazards) {
    final month = DateFormat('MMM').format(hazard.createdAt!); // Format to "Jan", "Feb", etc.
    hazardsByMonth[month] = (hazardsByMonth[month] ?? 0) + 1;
  }

  // 2. Create ChartData from grouped data
 final chartData = hazardsByMonth.entries.map((entry) => ChartData(entry.key, entry.value)).toList();

 //3. sort the data in the correct order from Jan to Dec
  final monthOrder = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  chartData.sort((a, b) => monthOrder.indexOf(a.x).compareTo(monthOrder.indexOf(b.x)));

  return BarChart(
    BarChartData(
      barGroups: 
        chartData.map((entry) {
                              return BarChartGroupData(
                                x: entry.y,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.y.toDouble(), // Number of hazards in the month
                                    color: Colors.blue, // Or any color scheme you want
                                    width: 20, // Adjust width as needed
                                  ),
                                ],
                              );
                            }).toList()
      ,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, // Reserve space for the labels
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < chartData.length) {
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(chartData[index].x), // Display month names
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 25),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
    ),
  );
}
  // For Incidents
  Widget _buildIncidentBarChart(List<HseIncident> incidents) {
    final incidentsByMonth = <String, int>{};
    for (final incident in incidents) {
      final month = DateFormat('MMM').format(incident.createdAt!); // Use incident.createdAt
      incidentsByMonth[month] = (incidentsByMonth[month] ?? 0) + 1;
    }

    final chartData = incidentsByMonth.entries.map((entry) => ChartData(entry.key, entry.value)).toList();

    final monthOrder = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    chartData.sort((a, b) => monthOrder.indexOf(a.x).compareTo(monthOrder.indexOf(b.x)));

      return BarChart(
    BarChartData(
      barGroups: 
        chartData.map((entry) {
                              return BarChartGroupData(
                                x: entry.y,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.y.toDouble(), // Number of hazards in the month
                                    color: Colors.blue, // Or any color scheme you want
                                    width: 20, // Adjust width as needed
                                  ),
                                ],
                              );
                            }).toList()
      ,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, // Reserve space for the labels
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < chartData.length) {
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(chartData[index].x), // Display month names
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 25),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
    ),
  );
  }
  // For Pending Tasks
  Widget _buildPendingTasksBarChart(List<HseTask> tasks) {
    final completedTasksByMonth = <String, int>{};
    for (final task in tasks) {
      if (task.status == 'pending') { // Filter for completed tasks
        final month = DateFormat('MMM').format(task.createdAt!); // Use task.completedAt or a relevant date field
        completedTasksByMonth[month] = (completedTasksByMonth[month] ?? 0) + 1;
      }
    }

    final chartData = completedTasksByMonth.entries.map((entry) => ChartData(entry.key, entry.value)).toList();

    final monthOrder = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    chartData.sort((a, b) => monthOrder.indexOf(a.x).compareTo(monthOrder.indexOf(b.x)));

  return BarChart(
    BarChartData(
      barGroups: 
        chartData.map((entry) {
                              return BarChartGroupData(
                                x: entry.y,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.y.toDouble(), // Number of hazards in the month
                                    color: Colors.blue, // Or any color scheme you want
                                    width: 20, // Adjust width as needed
                                  ),
                                ],
                              );
                            }).toList()
      ,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, // Reserve space for the labels
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < chartData.length) {
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(chartData[index].x), // Display month names
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 25),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
    ),
  );
  }
  // For Completed Tasks
  Widget _buildCompletedTasksBarChart(List<HseTask> tasks) {
    final completedTasksByMonth = <String, int>{};
    for (final task in tasks) {
      if (task.status == 'done') { // Filter for completed tasks
        final month = DateFormat('MMM').format(task.createdAt!); // Use task.completedAt or a relevant date field
        completedTasksByMonth[month] = (completedTasksByMonth[month] ?? 0) + 1;
      }
    }

    final chartData = completedTasksByMonth.entries.map((entry) => ChartData(entry.key, entry.value)).toList();

    final monthOrder = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    chartData.sort((a, b) => monthOrder.indexOf(a.x).compareTo(monthOrder.indexOf(b.x)));

      return BarChart(
    BarChartData(
      barGroups: 
        chartData.map((entry) {
                              return BarChartGroupData(
                                x: entry.y,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.y.toDouble(), // Number of hazards in the month
                                    color: Colors.blue, // Or any color scheme you want
                                    width: 20, // Adjust width as needed
                                  ),
                                ],
                              );
                            }).toList()
      ,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, // Reserve space for the labels
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < chartData.length) {
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(chartData[index].x), // Display month names
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 25),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
    ),
  );
  }
  //
  Widget _buildHazardsInLocationBarChart(List<HseHazard> hazards){
    // 1. Group Hazards by Location
    final hazardsByLocation = <String, int>{};
    for (final hazard in hazards) {
      final location = hazard.location ?? 'Unknown Location'; // Use location from HseHazard, default to 'Unknown' if null
      hazardsByLocation[location] = (hazardsByLocation[location] ?? 0) + 1;
    }

    // 2. Create ChartData from grouped data
    final chartData = hazardsByLocation.entries.map((entry) => ChartData(entry.key, entry.value)).toList();

    //no need to sort this one, it's not date data.

    return BarChart(
      BarChartData(
        barGroups: 
          chartData.asMap().entries.map((entry) {
                                final index = entry.key;
                                final chartData = entry.value;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: chartData.y.toDouble(), // Number of hazards in the location
                                      color: Colors.blue, // Or any color scheme you want
                                      width: 20, // Adjust width as needed
                                    ),
                                  ],
                                );
                              }).toList()
        ,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Reserve space for the labels
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartData.length) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(chartData[index].x,style: TextStyle(fontSize: 10)),
                    ) ,// Display location names
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 25),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  } 


  Widget _buildKpisTab(BuildContext context){
    final cubit = context.read<AdminCubit>();
    return  BlocBuilder<AdminCubit, UpdateAdminData>(
      bloc: cubit,    
      builder: (BuildContext context, UpdateAdminData state) {
        return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        spacing: 10,
                        children: [
                        // targetHazardIdsPerYear
                        FormTextField(
                                      labelText: 'targetHazardIdsPerYearTitle'.tr(),
                                      hintText: 'targetHazardIdsPerYearMessage'.tr(),
                                      initialValue: state.targetHazardIdsPerYear.round().toString(),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        context.read<AdminCubit>().updateSetting('targetHazardIdsPerYear', int.parse(value));
                                      },
                                    ),
                        // targetUncompletedTasksPerYear
                        FormTextField(
                                labelText: 'targetUncompletedTasksPerYearTitle'.tr(),
                                hintText: 'targetUncompletedTasksPerYearMessage'.tr(),
                                initialValue: state.targetUncompletedTasksPerYear.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  context.read<AdminCubit>().updateSetting('targetUncompletedTasksPerYear',  int.parse(value));
                                },
                              ),
                        // targetMiniSessionHrsPerYearPerUser
                        FormTextField(
                                labelText: 'targetMiniSessionHrsPerYearPerUserTitle'.tr(),
                                hintText: 'targetUncompletedTasksPerYearMessage'.tr(),
                                initialValue: state.targetMiniSessionHrsPerYearPerUser.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  context.read<AdminCubit>().updateSetting('targetUncompletedTasksPerYear',  int.parse(value));
                                },
                              ),
                      ],),
                    )
                    
                  );
      }
    );
  }

  Widget _buildPointsTab(BuildContext context){
    final cubit = context.read<AdminCubit>();
    return BlocBuilder<AdminCubit, UpdateAdminData>(
      bloc: cubit,
      builder: (BuildContext context, UpdateAdminData state){
        return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          spacing: 8,
                          children: [
                            // First Use Points
                            FormTextField(
                              labelText: 'firstUsePointsTitle'.tr(),
                              hintText: 'firstUsePointsMessage'.tr(),
                              initialValue: state.firstUsePoints.round().toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AdminCubit>().updateSetting('firstUsePoints',  int.parse(value));
                              },
                            ),
                            //createHazardPoints
                            FormTextField(
                              labelText: 'createHazardPointsTitle'.tr(),
                              hintText: 'createHazardPointsMessage'.tr(),
                              initialValue: state.createHazardPoints.round().toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AdminCubit>().updateSetting('createHazardPoints',  int.parse(value));
                              },
                            ),
                            //createTaskPoints
                            FormTextField(
                              labelText: 'createTaskPointsTitle'.tr(),
                              hintText: 'createTaskPointsMessage'.tr(),
                              initialValue: state.createTaskPoints.round().toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AdminCubit>().updateSetting('createTaskPoints',  int.parse(value));
                              },
                            ),
                            //createTaskPoints
                            FormTextField(
                              labelText: 'finishTaskPointsTitle'.tr(),
                              hintText: 'finishTaskPointsMessage'.tr(),
                              initialValue: state.finishTaskPoints.round().toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AdminCubit>().updateSetting('finishTaskPoints',  int.parse(value));
                              },
                            ),
                            //createIncidentPoints
                            FormTextField(
                              labelText: 'createIncidentPointsTitle'.tr(),
                              hintText: 'createIncidentPointsMessage'.tr(),
                              initialValue: state.createIncidentPoints.round().toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AdminCubit>().updateSetting('createIncidentPoints',  int.parse(value));
                              },
                            ),
                            //miniSessionPoints
                            FormTextField(
                              labelText: 'miniSessionPointsTitle'.tr(),
                              hintText: 'miniSessionPointsMessage'.tr(),
                              initialValue: state.miniSessionPoints.round().toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AdminCubit>().updateSetting('miniSessionPoints',  int.parse(value));
                              },
                            ),
                            //quizeGameAnswerPoints
                            FormTextField(
                              labelText: 'quizeGameAnswerPointsTitle'.tr(),
                              hintText: 'quizeGameAnswerPointsMessage'.tr(),
                              initialValue: state.quizeGameAnswerPoints.round().toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AdminCubit>().updateSetting('quizeGameAnswerPoints',  int.parse(value));
                              },
                            ),
                            //quizeGameLevelPoints
                            FormTextField(
                              labelText: 'quizeGameLevelPointsTitle'.tr(),
                              hintText: 'quizeGameLevelPointsMessage'.tr(),
                              initialValue: state.quizeGameLevelPoints.round().toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AdminCubit>().updateSetting('quizeGameLevelPoints',  int.parse(value));
                              },
                            ),
                            //appUsageDurationPoints
                            FormTextField(
                              labelText: 'appUsageDurationPointsTitle'.tr(),
                              hintText: 'appUsageDurationPointsMessage'.tr(),
                              initialValue: state.appUsageDurationPoints.round().toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AdminCubit>().updateSetting('appUsageDurationPoints',  int.parse(value));
                              },
                            ),
                          ]
                          ),
                      ),
                      
                      // SettingsList(
                      //                   sections: [
                      //                     SettingsSection(
                      //                       tiles: [
                      //                         // dark mode
                      //                         // First Use Points
                      //                         CustomSettingsTile(
                      //                           child: ListTile(
                      //                             title: Text('firstUsePointsTitle'.tr()),
                      //                             subtitle: Text(state.firstUsePoints.toString() ),
                      //                             trailing: SizedBox(
                      //                               width: 200,
                      //                               child: Slider(
                      //                                 value: state.firstUsePoints.toDouble(),
                      //                                 label: state.firstUsePoints.round().toString(),
                      //                                 min: 0,
                      //                                 max: 100,
                      //                                 divisions: 20,  // Optional: For discrete values
                      //                                 onChanged: (double value) {
                      //                                   //context.read<AdminCubit>().updateFirstUsePoints(value.toInt());
                      //                                   context.read<AdminCubit>().updateSetting('firstUsePoints', value.toInt());
                      //                                 },
                      //                               ),
                      //                             ),
                      //                           )
                      //                           ),
                                              
                      //                         CustomSettingsTile(
                      //                           child: ListTile(
                      //                             title: Text('createHazardPointsTitle'.tr()),
                      //                             subtitle: Text(state.createHazardPoints.toString() ),
                      //                             trailing: SizedBox(
                      //                               width: 200,
                      //                               child: Slider(
                      //                                 value: state.createHazardPoints.toDouble(),
                      //                                 label: state.createHazardPoints.round().toString(),
                      //                                 min: 0,
                      //                                 max: 100,
                      //                                 divisions: 20,  // Optional: For discrete values
                      //                                 onChanged: (double value) {
                      //                                   //context.read<AdminCubit>().updateCreateHazardPoints(value.toInt());
                      //                                   context.read<AdminCubit>().updateSetting('createHazardPoints', value.toInt());
                      //                                 },
                      //                               ),
                      //                             ),
                      //                           )
                      //                           ),
                                              
                      //                         CustomSettingsTile(
                      //                           child: ListTile(
                      //                             title: Text('createTaskPointsTitle'.tr()),
                      //                             subtitle: Text(state.createTaskPoints.toString() ),
                      //                             trailing: SizedBox(
                      //                               width: 200,
                      //                               child: Slider(
                      //                                 value: state.createTaskPoints.toDouble(),
                      //                                 label: state.createTaskPoints.round().toString(),
                      //                                 min: 0,
                      //                                 max: 100,
                      //                                 divisions: 20,  // Optional: For discrete values
                      //                                 onChanged: (double value) {
                      //                                   //context.read<AdminCubit>().updateCreateTaskPoints(value.toInt());
                      //                                   context.read<AdminCubit>().updateSetting('createTaskPoints', value.toInt());
                      //                                 },
                      //                               ),
                      //                             ),
                      //                           )
                      //                           ),
      
                      //                         CustomSettingsTile(
                      //                           child: ListTile(
                      //                             title: Text('finishTaskPointsTitle'.tr()),
                      //                             subtitle: Text(state.finishTaskPoints.toString() ),
                      //                             trailing: SizedBox(
                      //                               width: 200,
                      //                               child: Slider(
                      //                                 value: state.finishTaskPoints.toDouble(),
                      //                                 label: state.finishTaskPoints.round().toString(),
                      //                                 min: 0,
                      //                                 max: 100,
                      //                                 divisions: 20,  // Optional: For discrete values
                      //                                 onChanged: (double value) {
                      //                                   //context.read<AdminCubit>().updateFinishTaskPoints(value.toInt());
                      //                                   context.read<AdminCubit>().updateSetting('finishTaskPoints', value.toInt());
                      //                                 },
                      //                               ),
                      //                             ),
                      //                           )
                      //                           ),
      
                      //                         CustomSettingsTile(
                      //                           child: ListTile(
                      //                             title: Text('createIncidentPointsTitle'.tr()),
                      //                             subtitle: Text(state.createIncidentPoints.toString() ),
                      //                             trailing: SizedBox(
                      //                               width: 200,
                      //                               child: Slider(
                      //                                 value: state.createIncidentPoints.toDouble(),
                      //                                 label: state.createIncidentPoints.round().toString(),
                      //                                 min: 0,
                      //                                 max: 100,
                      //                                 divisions: 20,  // Optional: For discrete values
                      //                                 onChanged: (double value) {
                      //                                   //context.read<AdminCubit>().updateCreateIncidentPoints(value.toInt());
                      //                                   context.read<AdminCubit>().updateSetting('createIncidentPoints', value.toInt());
                      //                                 },
                      //                               ),
                      //                             ),
                      //                           )
                      //                           ),
                                            
                      //                         CustomSettingsTile(
                      //                           child: ListTile(
                      //                             title: Text('miniSessionPointsTitle'.tr()),
                      //                             subtitle: Text(state.miniSessionPoints.toString() ),
                      //                             trailing: SizedBox(
                      //                               width: 200,
                      //                               child: Slider(
                      //                                 value: state.miniSessionPoints.toDouble(),
                      //                                 label: state.miniSessionPoints.round().toString(),
                      //                                 min: 0,
                      //                                 max: 100,
                      //                                 divisions: 20,  // Optional: For discrete values
                      //                                 onChanged: (double value) {
                      //                                   //context.read<AdminCubit>().updateMiniSessionPoints(value.toInt());
                      //                                   context.read<AdminCubit>().updateSetting('miniSessionPoints', value.toInt());
                      //                                 },
                      //                               ),
                      //                             ),
                      //                           )
                      //                           ),
      
                      //                         CustomSettingsTile(
                      //                           child: ListTile(
                      //                             title: Text('quizeGameAnswerPointsTitle'.tr()),
                      //                             subtitle: Text(state.quizeGameAnswerPoints.toString() ),
                      //                             trailing: SizedBox(
                      //                               width: 200,
                      //                               child: Slider(
                      //                                 value: state.quizeGameAnswerPoints.toDouble(),
                      //                                 label: state.quizeGameAnswerPoints.round().toString(),
                      //                                 min: 0,
                      //                                 max: 100,
                      //                                 divisions: 50,  // Optional: For discrete values
                      //                                 onChanged: (double value) {
                      //                                   //context.read<AdminCubit>().updateQuizeGameAnswerPoints(value.toInt());
                      //                                   context.read<AdminCubit>().updateSetting('quizeGameAnswerPoints', value.toInt());
                      //                                 },
                      //                               ),
                      //                             ),
                      //                           )
                      //                           ),
                                              
                      //                         CustomSettingsTile(
                      //                           child: ListTile(
                      //                             title: Text('quizeGameLevelPointsTitle'.tr()),
                      //                             subtitle: Text(state.quizeGameLevelPoints.toString() ),
                      //                             trailing: SizedBox(
                      //                               width: 200,
                      //                               child: Slider(
                      //                                 value: state.quizeGameLevelPoints.toDouble(),
                      //                                 label: state.quizeGameLevelPoints.round().toString(),
                      //                                 min: 0,
                      //                                 max: 100,
                      //                                 divisions: 50,  // Optional: For discrete values
                      //                                 onChanged: (double value) {
                      //                                   //context.read<AdminCubit>().updateQuizeGameLevelPoints(value.toInt());
                      //                                   context.read<AdminCubit>().updateSetting('quizeGameLevelPoints', value.toInt());
                      //                                 },
                      //                               ),
                      //                             ),
                      //                           )
                      //                           ),
      
                      //                         CustomSettingsTile(
                      //                           child: ListTile(
                      //                             title: Text('appUsageDurationPointsTitle'.tr()),
                      //                             subtitle: Text(state.appUsageDurationPoints.toString() ),
                      //                             trailing: SizedBox(
                      //                               width: 200,
                      //                               child: Slider(
                      //                                 value: state.appUsageDurationPoints.toDouble(),
                      //                                 label: state.appUsageDurationPoints.round().toString(),
                      //                                 min: 0,
                      //                                 max: 50,
                      //                                 //divisions: 10,  // Optional: For discrete values
                      //                                 onChanged: (double value) {
                      //                                   //context.read<AdminCubit>().updateAppUsageDurationPoints(value.toInt());
                      //                                   context.read<AdminCubit>().updateSetting('appUsageDurationPoints', value.toInt());
                      //                                 },
                      //                               ),
                      //                             ),
                      //                           )
                      //                           ),
                                              
                      //                       ],
                      //                     ),
                      //                   ],
                      //                 ),
                    );
      }
    );
  }

  Widget _buildLocationTab(BuildContext context){
    final editLocationController = TextEditingController();
    final cubit = context.read<AdminCubit>();
    return BlocConsumer<AdminCubit, UpdateAdminData>(
      bloc: cubit,
        listener: (BuildContext context, UpdateAdminData state) {
                  if (state.status == FormStatus.failure) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage==null? 'error'.tr():'error'.tr(args:  [state.errorMessage??""])),
                        ),
                      );
                  }
                  },
      builder: (context, state){
          return Column(
            children: [         
              Expanded(
                    child: ListView.builder(
                      itemCount: state.locations.length,
                      itemBuilder: (context, index) {
                        return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                semanticContainer : false,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: ListTile(
                                            title: Text(state.locations[index].description,
                                            ),
                                            trailing:state.locations[index].description=='all'?null: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: (){
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text('rename'.tr()),
                                                          content: TextField(
                                                            controller: editLocationController,
                                                            decoration: InputDecoration(hintText: "newLocationString".tr()),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: Text('cancel'.tr()),
                                                              onPressed: () {
                                                                
                                                                Navigator.pop(context);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Text('ok'.tr()),
                                                              onPressed: () async {
                                                                _log.i(editLocationController.text);
                                                                await cubit.renameLocation(index,editLocationController.text);
                                                                if(context.mounted) Navigator.pop(context);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: const Icon(Icons.edit),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async{
                                                    final result= await _showOkCancelDialog(
                                                      context,
                                                      title: 'deleteConfirmTitle'.tr(),
                                                      contentMain: 'deleteConfirmMessage'.tr(),
                                                    );
                                                    if (result && context.mounted) {
                                                      await context.read<AdminCubit>().removeLocation(index);
                                                    }
                                                    },
                                                  child: const Icon(Icons.delete),
                                                ),
                                              ],
                                            )
                                          ),
                                ),
                              );
                      },
                    ),
                  ),
            ],
          );
        }
    );
  }
  
  Future<bool> _showOkCancelDialog(BuildContext context,{
    required String title,
    required String contentMain,
    String contentSecondary='',
  }) async {
    bool result =false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(contentMain),
                Text(contentSecondary),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: (){
                result = true;
                if(context.mounted) Navigator.pop(context);
              } ,
              child: Text('ok'.tr()),
            ),
            TextButton(
              onPressed:(){
                result = false;
                if(context.mounted) Navigator.pop(context);
              },
              child: Text('cancel'.tr()),
            ),
          ],
        );
      },
    );
    return result; 
  }

}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    final userPointsData = cubit.getUserPointsData();
    return Container(
              color: const Color(0xfff0f0f0),
              child: ListView(
                padding: const EdgeInsets.all(20),
                
                children: <Widget>[
                  if(userPointsData.isNotEmpty)
                  _buildChartContainer(
                    context,
                    title: 'User Points',
                    chart: _buildBarChart(userPointsData),
                  ),
                  if(cubit.hseHazards.isNotEmpty)
                  _buildChartContainer(
                    context,
                    title: 'Hazard Reports per Month',
                    chart: _buildHazardBarChart(cubit.hseHazards),
                  ),
                  if(cubit.hseIncidents.isNotEmpty)
                  _buildChartContainer(
                    context,
                    title: 'Incident Reports per Month',
                    chart: _buildIncidentBarChart(cubit.hseIncidents),
                  ),
                  if(cubit.hseTasks.isNotEmpty)
                  _buildChartContainer(
                    context,
                    title: 'Completed Actions',
                    chart: _buildCompletedTasksBarChart(cubit.hseTasks),
                  ),
                  if(cubit.hseTasks.isNotEmpty)
                  _buildChartContainer(
                    context,
                    title: 'Pending Actions',
                    chart: _buildPendingTasksBarChart(cubit.hseTasks),
                  ),
                ],
              ),
            );
  }

  // Widget _buildChartContainer({required String title, required Widget chart}) {
  //   return Card(
  //     elevation: 2,
  //     margin: const EdgeInsets.only(bottom: 20),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             title,
  //             style: const TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const SizedBox(height: 10),
  //           chart,
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildChartContainer(BuildContext context, {required String title, required Widget chart}) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.width * 0.95 * 0.65,
        padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey, width: 1)
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

  Widget _buildBarChart(List<ChartData> data) {
    return BarChart(
      BarChartData(
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final chartData = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: chartData.y.toDouble(),
                width: 20, // Adjust bar width as needed
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
           show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return SideTitleWidget(
                    meta: meta,
                    space: 4, // Adjust spacing as needed
                    child: Text(data[index].x),
                  );
                  }
                  return const Text('');
                },
              reservedSize: 30,
              ),
            ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true,reservedSize: 25 ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
  
  //for hazards
  Widget _buildHazardBarChart(List<HseHazard> hazards) {
  // 1. Group Hazards by Month
  final hazardsByMonth = <String, int>{};
  for (final hazard in hazards) {
    final month = DateFormat('MMM').format(hazard.createdAt!); // Format to "Jan", "Feb", etc.
    hazardsByMonth[month] = (hazardsByMonth[month] ?? 0) + 1;
  }

  // 2. Create ChartData from grouped data
 final chartData = hazardsByMonth.entries.map((entry) => ChartData(entry.key, entry.value)).toList();

 //3. sort the data in the correct order from Jan to Dec
  final monthOrder = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  chartData.sort((a, b) => monthOrder.indexOf(a.x).compareTo(monthOrder.indexOf(b.x)));

  return BarChart(
    BarChartData(
      barGroups: 
        chartData.map((entry) {
                              return BarChartGroupData(
                                x: entry.y,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.y.toDouble(), // Number of hazards in the month
                                    color: Colors.blue, // Or any color scheme you want
                                    width: 20, // Adjust width as needed
                                  ),
                                ],
                              );
                            }).toList()
      ,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, // Reserve space for the labels
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < chartData.length) {
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(chartData[index].x), // Display month names
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 25),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
    ),
  );
}
  // For Incidents
  Widget _buildIncidentBarChart(List<HseIncident> incidents) {
    final incidentsByMonth = <String, int>{};
    for (final incident in incidents) {
      final month = DateFormat('MMM').format(incident.createdAt!); // Use incident.createdAt
      incidentsByMonth[month] = (incidentsByMonth[month] ?? 0) + 1;
    }

    final chartData = incidentsByMonth.entries.map((entry) => ChartData(entry.key, entry.value)).toList();

    final monthOrder = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    chartData.sort((a, b) => monthOrder.indexOf(a.x).compareTo(monthOrder.indexOf(b.x)));

      return BarChart(
    BarChartData(
      barGroups: 
        chartData.map((entry) {
                              return BarChartGroupData(
                                x: entry.y,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.y.toDouble(), // Number of hazards in the month
                                    color: Colors.blue, // Or any color scheme you want
                                    width: 20, // Adjust width as needed
                                  ),
                                ],
                              );
                            }).toList()
      ,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, // Reserve space for the labels
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < chartData.length) {
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(chartData[index].x), // Display month names
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 25),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
    ),
  );
  }
  // For Pending Tasks
  Widget _buildPendingTasksBarChart(List<HseTask> tasks) {
    final completedTasksByMonth = <String, int>{};
    for (final task in tasks) {
      if (task.status == 'pending') { // Filter for completed tasks
        final month = DateFormat('MMM').format(task.createdAt!); // Use task.completedAt or a relevant date field
        completedTasksByMonth[month] = (completedTasksByMonth[month] ?? 0) + 1;
      }
    }

    final chartData = completedTasksByMonth.entries.map((entry) => ChartData(entry.key, entry.value)).toList();

    final monthOrder = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    chartData.sort((a, b) => monthOrder.indexOf(a.x).compareTo(monthOrder.indexOf(b.x)));

  return BarChart(
    BarChartData(
      barGroups: 
        chartData.map((entry) {
                              return BarChartGroupData(
                                x: entry.y,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.y.toDouble(), // Number of hazards in the month
                                    color: Colors.blue, // Or any color scheme you want
                                    width: 20, // Adjust width as needed
                                  ),
                                ],
                              );
                            }).toList()
      ,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, // Reserve space for the labels
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < chartData.length) {
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(chartData[index].x), // Display month names
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 25),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
    ),
  );
  }
  // For Completed Tasks
  Widget _buildCompletedTasksBarChart(List<HseTask> tasks) {
    final completedTasksByMonth = <String, int>{};
    for (final task in tasks) {
      if (task.status == 'done') { // Filter for completed tasks
        final month = DateFormat('MMM').format(task.createdAt!); // Use task.completedAt or a relevant date field
        completedTasksByMonth[month] = (completedTasksByMonth[month] ?? 0) + 1;
      }
    }

    final chartData = completedTasksByMonth.entries.map((entry) => ChartData(entry.key, entry.value)).toList();

    final monthOrder = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    chartData.sort((a, b) => monthOrder.indexOf(a.x).compareTo(monthOrder.indexOf(b.x)));

      return BarChart(
    BarChartData(
      barGroups: 
        chartData.map((entry) {
                              return BarChartGroupData(
                                x: entry.y,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.y.toDouble(), // Number of hazards in the month
                                    color: Colors.blue, // Or any color scheme you want
                                    width: 20, // Adjust width as needed
                                  ),
                                ],
                              );
                            }).toList()
      ,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, // Reserve space for the labels
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < chartData.length) {
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(chartData[index].x), // Display month names
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 25),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
    ),
  );
  }

}

class UsersListAdminPage extends StatelessWidget {
  const UsersListAdminPage({super.key});
  @override
  Widget build(BuildContext context) {
    final _log = LoggerReprository('UsersListAdminPage');
    return BlocConsumer <AdminCubit, UpdateAdminData>(
      listener: (context, state) async {
          },
        builder:(context, state) {
          final _cubit = context.read<AdminCubit>();
          return state.loadingUserData?
        const Center(child: CircularProgressIndicator()):
        Column(
          children: [
            IconButton(
                    onPressed: () async {
                      final result = await showSearch<String>(
                        context: context,
                        delegate: UserAdminSearch(
                          authUsers: _cubit.userList, // Pass your equipment list here
                          selectedIndeces: {}, // Pass your selected indices set
                        ),
                      );
                      if (result != null) {
                        // Handle the search result
                      }
                    },
                    icon: const Icon(Icons.search),
                  ),
            Expanded(
              child: state.loadingUserData
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    itemCount: _cubit.userList.length,
                    itemBuilder: (context, index) {
                      final item = _cubit.userList[index];
                      //log.i(item);
                      final mainText = '${item.firstName} ${item.lastName} ';
                      final subText = '${item.currentWorkplaceRole}';
                      return InkWell(
                                onTap: () {
                                  if(state.userSelectionMode) {
                                    _cubit.userItemTapped(index);
                                  }else{
                                    context.goNamed(AppPage.workplaceUser.name,extra: {'item':   item.toMap()});
                                  }
                                },
                                onLongPress: () {
                                  {
                                  _cubit.userItemTapped(index);
                                  _cubit.userItemLongTapped();
                              // Show the menu when the list item is tapped
                              showMenu<String>(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  MediaQuery.of(context).size.width, // Show menu at the right edge
                                  // Adjust top and bottom based on your item's position
                                  100.0, 
                                  0.0, 
                                  100.0, 
                                ),
                                items: [
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ).then((value) {
                                // Handle the selected menu item
                                if (value != null) {
                                  switch (value) {
                                    case 'edit':
                                      // Handle edit action
                                      _log.i('Edit : $value');
                                      break;
                                    case 'delete':
                                      // Handle delete action
                                      _log.i('Delete : $value');
                                      break;
                                  }
                                }});} 
                                },
                            child:ListTile(
                              leading: item.photoURL !=null 
                                      ? CircleAvatar( // Use a nested CircleAvatar for preview
                                          radius: 30,
                                          backgroundImage: Image.network(
                                            item.photoURL??'',
                                            cacheWidth: 100, // Adjust as needed
                                            cacheHeight: 100,
                                          ).image, // Display from File
                                      )
                                      : Icon(
                                          Icons.person,
                                          size: 30,
                                          color: Colors.grey[400],
                                        ),
                              title: Text(mainText),
                              subtitle: Text(subText),
                              trailing: state.userSelectionMode
                                      ? (state.selectedUserIndeces
                                              .contains(index)
                                          ? const Icon(
                                              Icons.check_box,
                                              color: Colors.black,
                                            )
                                          : const Icon(
                                              Icons.check_box_outline_blank,
                                              color: Colors.black,
                                            )):null)
                              
                            
                              );
                    },
                  ),
            )
        ],);
    }
    );
  }
}

class UserAdminSearch extends SearchDelegate<String> {
  final List<AuthUser> authUsers;
  final Set<int> selectedIndeces;

  UserAdminSearch({required this.authUsers,required this.selectedIndeces});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // This gets called each time the text in the search bar changes
    final searchResults = authUsers.where((authUser) {
      final itemNo = authUser.firstName?.toLowerCase()??'';
      final desc = authUser.lastName?.toLowerCase()??'';
      final searchQuery = query.toLowerCase();
      return itemNo.contains(searchQuery) || desc.contains(searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        final mainText = "${item.firstName} ${item.lastName}";
        final subText = "${item.currentWorkplaceRole}";
        return InkWell(
                      onTap: () {
                        //context.read<HomeBloc>().add(GreaseItemTappedHomeEvent(index));
                      },
                  child:ListTile(
                    title: Text(mainText),
                    subtitle: Text(subText),
                    trailing: selectedIndeces.contains(index)
                                ? const Icon(
                                    Icons.done,
                                    color: Colors.black,
                                  )
                                : null)
                    );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This gets called when the user submits the search
    final suggestionList = authUsers.where((authUser) {
      final itemNo = authUser.firstName?.toLowerCase()??'';
      final desc = authUser.lastName?.toLowerCase()??'';
      final searchQuery = query.toLowerCase();
      return itemNo.contains(searchQuery) || desc.contains(searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final item = suggestionList[index];
        final mainText = "${item.firstName} ${item.lastName}";
        final subText = "${item.currentWorkplaceRole} ";
        return Card(
          margin: const EdgeInsets.all(0.0),
          child: InkWell(
                      onTap: () {
                        context.goNamed(AppPage.workplaceUser.name,extra: {'item':   item.toMap()});
                      },
                  child:ListTile(
                    title: Text(mainText),
                    subtitle: Text(subText),
                    trailing: selectedIndeces.contains(index)
                                ? const Icon(
                                    Icons.done,
                                    color: Colors.black,
                                  )
                                : null)
                    ),
        );
      },
    );
  }
}