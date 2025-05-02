import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/enums/form_status.dart';
import '../blocs/workplace_user_bloc.dart';

class WorkplaceUserPage extends StatelessWidget {
  const WorkplaceUserPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Container(
              margin: const EdgeInsets.all(10.0),
              child: Expanded(
                      child: Text('informationLabel'.tr(),
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                    ))),
      body: BlocConsumer<WorkplaceUserCubit, WorkplaceUserUpdate>(
              listener: (BuildContext context, WorkplaceUserUpdate state) {
                if (state.status.isFailure) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content:  Text(state.errorMessage==null? 'error'.tr():'error'.tr(args:  [state.errorMessage??""])),
                      ),
                    );
                }
                if (state.status.isSuccess) {
                  context.pop();
                }
              }, 
              builder: (BuildContext context, WorkplaceUserUpdate state) {
                final cubit = context.read<WorkplaceUserCubit>();
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(width: 4, color: Colors.black),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //name and mail
                        Align(
                          alignment: Alignment.topCenter,
                          child: ListTile(
                            title: Text("${cubit.user.firstName} ${cubit.user.lastName}"),
                            subtitle: Text(cubit.user.email )
                            ),
                        ),
                        //role
                        DropdownMenu<String>(
                              enabled: cubit.user.currentWorkplaceRole != 'admin',
                              expandedInsets: EdgeInsets.zero,
                              label: Text('role'.tr()),
                              leadingIcon: const Icon(Icons.title),
                              initialSelection: cubit.state.role == 'admin'?'admin': cubit.state.role,
                              onSelected: (String? value) {
                                // This is called when the user selects an item.
                                if(value!=null){
                                  cubit.updateRole(value);
                                } 
                              },
                              dropdownMenuEntries: cubit.userRoles.map<DropdownMenuEntry<String>>((String value) {
                                return DropdownMenuEntry<String>(value: value, label: value);
                              }).toList(),
                        ),
                        const SizedBox(height: 10),
                        //Buttons
                        Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                width: double.infinity, // Full width
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            backgroundColor:
                                                state.isValid ? Colors.white : Colors.grey,
                                          ),
                                          onPressed: state.isValid || state.status.isInProgress
                                              ? () => 
                                                  cubit.updateUser()
                                              : null,
                                          child:
                                              Text(cubit.state.status.isInProgress ? '...' : 'ok'.tr())),
                                ),
                              ),
                            )
                      ],
                    ),
                );
              }
            ),
      
    );
  }
}
