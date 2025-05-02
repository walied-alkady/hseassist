import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/enums/form_status.dart';

import '../blocs/workplace_location_bloc.dart';
import '../repository/logging_reprository.dart';



class WorkplaceLocationPage extends StatelessWidget {
  const WorkplaceLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
final _log = LoggerReprository('WorkplaceLocationPage'); 
    final bloc = context.watch<WorkplaceLocationCubit>()..initForm();
    return Scaffold(
      appBar: AppBar(
        title: Text('locationText'.tr()),
      ),
      body: BlocConsumer<WorkplaceLocationCubit,WorkplaceLocationState>(
        bloc: bloc,
        listenWhen: (previous, current) => current.status.isFailure,
        listener: (BuildContext context, WorkplaceLocationState state) {
                _log.i(state);
                if (state.status.isFailure) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content:  Text(state.errorMessage==null? 'error'.tr():'error'.tr(args:  [state.errorMessage??""])),
                      ),
                    );
                }
              },
        builder: (context, state){
          _log.i('builder state changed...${state.addText}');
          
          return Column(
            children: [
              ListTile(
                    title: TextField(
                      decoration: InputDecoration(
                        label: Text("addLocationLabel".tr())
                      ),
                      onChanged: context.read<WorkplaceLocationCubit>().addLocationTextChaned,
                    ),
                    subtitle:state.editMessage!=null? Text(state.editMessage!):null,
                    trailing: ElevatedButton(
                      onPressed: ()=> context.read<WorkplaceLocationCubit>().addLocation(),
                      child: Text('ok'.tr()),
                  )),
          
              // BlocBuilder<WorkplaceLocationCubit,WorkplaceLocationState>(
              //   builder:(context, state) {
              //     return Offstage(
              //       offstage: state.message !=null,
              //       child:Text(state.message ?? ''),
              //     );
              //   }
              // ),
              Expanded(
                    child: ListView.builder(
                      itemCount: state.locations.length,
                      itemBuilder: (context, index) {
                        
                        final controller = TextEditingController(text: state.modifyValue);
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
                                  child: ExpansionTile(
                                            shape: const Border(),
                                            title: Text(state.locations[index].description),
                                            controlAffinity: ListTileControlAffinity.leading,
                                            children: [
                                                Row(
                                                  children: [
                                                  Expanded(
                                                    child: 
                                                    TextField(
                                                      controller: controller,
                                                      decoration:InputDecoration(
                                                        label: Text("descriptionLabel".tr())
                                                      ),
                                                      onChanged: (value){
                                                        controller.text = value;
                                                        context.read<WorkplaceLocationCubit>().renameLocation(index,value);
                                                        },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: (){
                                                      context.read<WorkplaceLocationCubit>().renameLocationSubmit();
                                                      controller.clear();
                                                      } ,
                                                    icon: const Icon(Icons.send),
                                                  )
                                                ],
                                                ),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: TextButton.icon(
                                                            onPressed: () => context.read<WorkplaceLocationCubit>().removeLocation(index),
                                                            icon: const Icon(Icons.delete),
                                                            label: Text(
                                                              'delete'.tr(),
                                                            ),
                                                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                          )
                                                  
                                                ),
                                            ],
                                            onExpansionChanged: (bool expanded) {
                                              //_customTileExpanded = expanded;
                                            },
                                          ),
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
}
  