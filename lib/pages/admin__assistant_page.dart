import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../blocs/admin_bloc.dart';
import '../enums/app_page.dart';
import '../models/models.dart';
import '../repository/logging_reprository.dart';
import '../service/authentication_service.dart';

class AdminAssistantPage extends StatelessWidget {
  const AdminAssistantPage({super.key});
  @override
  Widget build(BuildContext context) {
    bool loading=false;
    return BlocBuilder<AdminCubit, UpdateAdminData>(
        builder: (BuildContext context, UpdateAdminData state) {
          final _cubit = context.read<AdminCubit>();
          return DefaultTabController(
            length: 1,
            initialIndex: state.tabIndex,
            child: Scaffold(
              appBar: AppBar(
                title: Text('admin'.tr()),
                bottom: const TabBar(
                  //isScrollable: true,
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.person_search),
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
                    _cubit.updateTabIndex(newIndex);
                    // Update the TabController's index
                    tabController.animateTo(newIndex);
                  });
                  return TabBarView(
                    controller: tabController,
                    children: const <Widget>[
                      Center(child: UsersListAdminPage()),
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
  
  Widget? _getFAB(BuildContext context, int index) {
    final authUser = GetIt.instance<AuthenticationService>();
    if ([2].contains(index)) {
      return FloatingActionButton(
        onPressed: () {
          if(index ==2 ){

            // context.goNamed(
            //   AppPage.equipment.name,
            //   extra: {'item':  
            //     {
            //       'id' : '',
            //       'itemNo': 'new',
            //       'desc': '',
            //       'type': '',
            //       'qtyDe': 0,
            //       'qtyNde': 0,
            //       'interval': 0,
            //       'greaseLubricant': '',
            //       'group': authUser.currentUser.group,
            //     }
            //     });
          }
          // Perform actions based on selected indices
        },
        child: const Icon(Icons.add),
      );
    } else {
      return null; // Hide the FAB when not in selection mode
    }
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