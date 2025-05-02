import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/enums/form_status.dart';
import '../blocs/recieve_invitation_bloc.dart';
import '../repository/logging_reprository.dart';

class RecieveInvitationPage extends StatelessWidget {
  const RecieveInvitationPage({super.key});
  @override
  Widget build(BuildContext context) {
    final _log = LoggerReprository('RecieveInvitationPage'); 
    return Scaffold(
      appBar: AppBar(
          title: Container(
              margin: const EdgeInsets.all(10.0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('joinOrganizationTitle'.tr(),
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                    ),
                    Image.asset('assets/images/logo.jpg',
                        width: 70.0, height: 70.0),
                  ]))),
      body: BlocListener<RecieveInvitationCubit, RecieveInvitationFormUpdate>(
        listener: (context, state) {
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
                ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('success'.tr()),
                ),
              );
              Navigator.pop(context);
          }

        },
        child: BlocConsumer<RecieveInvitationCubit, RecieveInvitationFormUpdate>(
            listener: (BuildContext context, RecieveInvitationFormUpdate state) {
          _log.i(state);
        }, builder: (BuildContext context, RecieveInvitationFormUpdate state) {
          final _bloc = context.read<RecieveInvitationCubit>();
          return Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(width: 4, color: Colors.black),
            ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /*Image.asset(
                'images/logo.jpg',
                height: 120,
              ),*/
                  Align(
                    alignment: Alignment.topCenter,
                    child:Text(
                      state.workplaceName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)
                      )),
                  const SizedBox(height: 16),
                  ///invitation status (accept or reject)
                  DropdownMenu<String>(
                        expandedInsets: EdgeInsets.zero,
                        label: Text('invitationRecievedMessage'.tr(args: [state.workplaceName])),
                        leadingIcon: const Icon(Icons.insert_invitation),
                        initialSelection:'Approve',
                        onSelected: (String? value) {
                          // This is called when the user selects an item.
                          if(value!=null){
                            _bloc.updateInvitationResponse(value);
                          } 
                        },
                        dropdownMenuEntries: _bloc.statusSelection.map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(value: value, label: value);
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  //Buttons
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity, // Full width
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  backgroundColor:!state.status.isInProgress ? Colors.white : Colors.grey,
                                  textStyle: const TextStyle(fontSize: 20)),
                                  onPressed: state.status.isInProgress?null:
                                    () => _bloc.submitResponse(),
                                  child: Text(context.tr('ok'))
                                  ),
                      ),
                    ),
                  )
                ],
              ),
          );
        }),
      ),
    );
  }
  
}
