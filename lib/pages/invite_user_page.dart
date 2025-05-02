import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/enums/form_status.dart';

import '../blocs/invite_user_bloc.dart';
import '../blocs/validator.dart';
import '../repository/logging_reprository.dart';


class InviteUserPage extends StatelessWidget with Validator{
  InviteUserPage({super.key}); 
  final _log = LoggerReprository('InviteUserPage');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Expanded(
                      child: Text('sendInvitationTitle'.tr(),
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                    )),
      body: BlocConsumer<InviteUserCubit, InviteUserFormUpdate>(
            listener: (BuildContext context, InviteUserFormUpdate state) {
          _log.i(state);
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
                  content: Text('success'.tr()),
                ),
              );
              context.pop();
          }
        }, 
            builder: (BuildContext context, InviteUserFormUpdate state) {
              return inviteUserForm(context);
            }
            )
          );
  }
  
  Widget inviteUserForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _cubit = context.read<InviteUserCubit>();
    return Form(
              key: _formKey,
              autovalidateMode: _cubit.state.autovalidateMode,
              child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //email name
                      const SizedBox(height: 8),
                      TextFormField(
                        validator: validateName,
                        onChanged: (value) =>_cubit.updateEmail(value),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: _cubit.state.email.isEmpty ? 'email'.tr(): _cubit.state.email,
                          hintText: 'enterEmail'.tr(),
                          prefixIcon: const Icon(Icons.email),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      ///last name
                      const SizedBox(height: 10),
                      DropdownMenu<String>(
                            expandedInsets: EdgeInsets.zero,
                            label: Text('roleLabel'.tr()),
                            leadingIcon: const Icon(Icons.title),
                            initialSelection:_cubit.userRoles[1],
                            onSelected: (String? value) {
                              // This is called when the user selects an item.
                              if(value!=null){
                                _cubit.updateRole(value);
                              } 
                            },
                            dropdownMenuEntries: _cubit.userRoles.map<DropdownMenuEntry<String>>((String value) {
                              return DropdownMenuEntry<String>(value: value, label: value);
                            }).toList(),
                      ),
                     //Buttons
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if(context.mounted){
                                _cubit.sendInvitation();
                                context.pop();
                              }
                            } else {
                              // in case a user has submitted invalid form we'll set 
                              // AutovalidateMode.always which will rebuild the form
                              // in result we'll start getting error message
                              _cubit.updateAutovalidateMode(AutovalidateMode.always);
                            }
                          },
                          child: Text('ok'.tr()),
                        ),
                      ),
                    ],
                  ),
            );
  }
}
