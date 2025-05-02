import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/profile_bloc.dart';
import '../blocs/validator.dart';
import '../enums/form_status.dart';
import '../repository/logging_reprository.dart';

class ProfilePage extends StatelessWidget with Validator{
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final _log = LoggerReprository('ProfilePage');
    return Scaffold(
      appBar: AppBar(
          title: Expanded(
                      child: Text('profile'.tr(),
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                    )),
      body: Column(
        children: [
          BlocConsumer<ProfileCubit, ProfileFormUpdate>(
                listener: (BuildContext context, ProfileFormUpdate state) {
              _log.i(state);
              if (state.status == FormStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:  Text(state.errorMessage==null? 'error'.tr():'error'.tr(args:  [state.errorMessage??""])),
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
                builder: (BuildContext context, ProfileFormUpdate state) {
                  return profileForm(state, context);
                }
                ),
        ],
      )
          );
  }

  Widget profileForm(ProfileFormUpdate state, BuildContext context) {
    final _formKey = GlobalKey<FormState>();
        final _cubit = context.read<ProfileCubit>();
    return Form(
              key: _formKey,
              autovalidateMode: state.autovalidateMode,
              child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[50],
                          radius: 100,
                          child: GestureDetector(
                            onTap: () => context.read<ProfileCubit>().updatePhotoURL,
                            child: 
                            state.photoURL.isNotEmpty 
                                ? CircleAvatar( // Use a nested CircleAvatar for preview
                                    radius: 100,
                                    backgroundImage: Image.network(
                                      state.photoURL,
                                      cacheWidth: 200, // Adjust as needed
                                      cacheHeight: 200,
                                    ).image, // Display from File
                                )
                                : Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Colors.grey[400],
                                  ),
                          ),
                        ),
                      ),
                      //First name
                      const SizedBox(height: 8),
                      TextFormField(
                        validator: validateName,
                        onChanged: (value) =>_cubit.updateFirstName(value),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: state.firstName.isEmpty ? 'firstNamelabel'.tr(): state.firstName,
                          hintText: 'firstNameMessage'.tr(),
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      ///last name
                      const SizedBox(height: 8),
                      TextFormField(
                        validator: validateName,
                        onChanged: (value) =>_cubit.updateLastName(value),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: state.lastName.isEmpty ? 'lastNamelabel'.tr(): state.lastName,
                          hintText: 'lastNameMessage'.tr(),
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      ///displayName
                      const SizedBox(height: 8),
                      TextFormField(
                        validator: validateName,
                        onChanged: (value) =>_cubit.updateDisplayName(value),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: state.displayName.isEmpty ? 'displayNameLabel'.tr(): state.displayName,
                          hintText: 'displayNameMessage'.tr(),
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      ///displayNameLocal
                      const SizedBox(height: 8),
                      TextFormField(
                        validator: validateName,
                        onChanged: (value) =>_cubit.updateDisplayNameLocal(value),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: state.displayNameLocal.isEmpty ? 'displayNameLocalLabel'.tr(): state.displayNameLocal,
                          hintText: 'displayNameLocalMessage'.tr(),
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      //phone
                      const SizedBox(height: 8),
                      TextFormField(
                        validator: validateName,
                        onChanged: (value) =>_cubit.updateDisplayNameLocal(value),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: state.phoneNo.isEmpty ? 'phoneNoLabel'.tr(): state.phoneNo,
                          hintText: 'phoneNoMessage'.tr(),
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      //Notes
                      const SizedBox(height: 8),
                      TextFormField(
                        validator: validateName,
                        onChanged: (value) =>_cubit.updateDisplayNameLocal(value),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: state.notes.isEmpty ? 'notesLabel'.tr(): state.notes,
                          hintText: 'notesMessage'.tr(),
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      //Buttons
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await context.read<ProfileCubit>().saveProfile();
                              if(context.mounted){
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
