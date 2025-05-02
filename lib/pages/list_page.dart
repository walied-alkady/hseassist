import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/list_bloc.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ListCubit listCubit = context.read<ListCubit>()..initForm();
    final itemType = listCubit.state.items.firstOrNull?.type;
    return Scaffold(
      appBar: AppBar(
        title: const Text('List'),
      ),
      body: BlocBuilder<ListCubit, ListUpdate>(
        bloc: listCubit,
        builder: (context, state){
          return Column(
                spacing: 8,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if(itemType!=null && itemType.name != ItemType.task.name)  
                      ToggleButtons(
                          isSelected: listCubit.state.selections,
                          children: [Text("me".tr()), Text("all".tr())],
                          onPressed: (int index) {
                            listCubit.updateFilterSelect(index);
                          },
                        ),
                      IconButton(
                        onPressed: () async {
                          if(itemType !=null) {
                            final result = await showSearch<String>(
                                context: context,
                                delegate: ListSearch(
                                  items: listCubit.state.items, // Pass your equipment list here
                                  type: itemType, // Pass your selected indices set
                                ),
                            );
                            if (result != null && context.mounted) {
                                scrollToItem(result, context);
                            }
                          }                         
                        },
                        icon: const Icon(Icons.search),
                      ),
                    ]
                  ),
                  
                  Expanded(
                    child: ListView.builder(
                        controller: state.scrollController,
                        itemCount: listCubit.state.items.length,
                        itemBuilder: (context, index) {
                          final item = listCubit.state.items[index];
                          final TextEditingController feedbackController = TextEditingController();
                          return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: switch (item.type) {
                                        ItemType.task => ExpansionTile(
                                                        title: Text(item.title),
                                                        subtitle: Text(item.description),
                                                        trailing: _buildTrailingWidget(item),
                                                        children: <Widget>[
                                                            Row(children: [
                                                              Expanded( // Add this
                                                                child: TextField(
                                                                  controller: feedbackController,
                                                                  textInputAction: TextInputAction.send,
                                                                  decoration: InputDecoration(
                                                                    labelText: 'feedbackLabel'.tr(),
                                                                    hintText: "feedbackMessage".tr(),
                                                                  ),
                                                                ),
                                                              ), // Add this,
                                                              TextButton(
                                                              onPressed:(){
                                                                String feedbackText = feedbackController.text;
                                                                listCubit.taskFeedback(item.id, feedbackText);
                                                                feedbackController.clear(); // Clear the text field. Consider using setState to rebuild and clear if needed
                                                              }, 
                                                              child: Text('sendLabel'.tr())),
                                                            ],),
                                                            // Row(children: [
                                                            //   TextButton(
                                                            //   onPressed:()=>{
                                                            //     context.goNamed(AppPage.taskCreate.name,extra: {"task":item})
                                                            //   }, 
                                                            //   child: Text('View')),
                                              
                                                            // ],)
                                                        ],
                                                        onExpansionChanged: (bool expanded) {
                                                          //_customTileExpanded = expanded;
                                                        },
                                                      ),
                                        ItemType.incident=>  ListTile(
                                                                title: Text(item.title),
                                                                subtitle: Text(item.description),
                                                                trailing: _buildTrailingWidget(item),
                                                              ),
                                        ItemType.hazard => 
                                        ListTile(
                                                title: Text(item.title),
                                                subtitle: Text(item.description),
                                                leading: item.imageUrl.isNotEmpty?GestureDetector(
                                                  child: CircleAvatar(
                                                    radius: 25, // Adjust size as needed
                                                    backgroundImage: CachedNetworkImageProvider(item.imageUrl)
                                                        ), // Placeholder image
                                                  ):const Icon(Icons.warning),
                                                trailing: _buildTrailingWidget(item),
                                                onTap: (){
                                                      listCubit.viewHazard(context,item.id);
                                                    },
                                        )
                                       
                                      },                      
                                  ),
                                );
                        },
                      ),
                  ),
                ],
              );
        }
      ),
    );
  }

  Widget _buildTrailingWidget(ListItem item) {
    switch (item.type) {
      case ItemType.task:
        return Column(
          children: [
            Text((item as TaskItem).dueDate.year!=9999 ? DateFormat('yyyy-MM-dd').format(item.dueDate) :"-"),
            Text((item).status),
          ],
        );
      case ItemType.incident:
        return Column(
          children: [
            Text(DateFormat('yyyy-MM-dd').format((item as IncidentItem).date)),
          ],
        );
      case ItemType.hazard:
        return Text((item as HazardItem).location);
    }
  }

  void scrollToItem(String itemId, BuildContext context) {
    final ListCubit listCubit = context.read<ListCubit>();
    final items = context.read<ListCubit>().state.items; // Access items from ListCubit
    final index = items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      listCubit.state.scrollController?.animateTo(
        index * 72.0, // Adjust item height as needed
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}

// Common interface
abstract class ListItem {
  String get id;
  String get title;
  String get description;
  String get imageUrl;
  ItemType get type; // Important: To distinguish item type
}

class TaskItem implements ListItem {
  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final ItemType type = ItemType.task; // Set the type here
  final DateTime dueDate;
  final String status;

  TaskItem({
    required this.id, 
  required this.title, 
  required this.description, 
  required this.dueDate,
  required this.status
  });
  
  @override
  // TODO: implement imageUrl
  String get imageUrl => throw UnimplementedError();
}

class IncidentItem implements ListItem {
  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final ItemType type = ItemType.incident; // Set the type here
  final DateTime date;
  @override
  final String imageUrl;

  IncidentItem({required this.id,required this.title, required this.description, required this.date, this.imageUrl = ''});
}

class HazardItem implements ListItem {
  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final ItemType type = ItemType.hazard; // Set the type here
  final String location;
  @override
  final String imageUrl;
  HazardItem({required this.id,required this.title, required this.description, required this.location, this.imageUrl= ''});
}

enum ItemType { task, incident, hazard }

class ListSearch extends SearchDelegate<String> {
  final List<ListItem> items;
  final ItemType type;
  
  ListSearch({required this.items,required this.type});

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
    final searchResults = items.where((item) {
      final itemNo = item.description.toLowerCase();
      final searchQuery = query.toLowerCase();
      return itemNo.contains(searchQuery) ;
    }).toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        final mainText = item.title;
        final subText = item.description;
        return InkWell(
                onTap: () {
                  //context.read<HomeBloc>().add(GreaseItemTappedHomeEvent(index));
                },
                child:ListTile(
                  title: Text(mainText),
                  subtitle: Text(subText),
                  )
                    );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This gets called when the user submits the search
    final suggestionList = items.where((item) {
      final itemNo = item.description.toLowerCase();
      final searchQuery = query.toLowerCase();
      return itemNo.contains(searchQuery) ;
    }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final item = suggestionList[index];
        final mainText = item.title;
        final subText = "${item.description} ";
        return Card(
          margin: const EdgeInsets.all(0.0),
          child: InkWell(
                      onTap: () {
                        close(context, item.id);
                      },
                  child:ListTile(
                    title: Text(mainText),
                    subtitle: Text(subText),
                  )
                    ),
        );
      },
    );
  }
}