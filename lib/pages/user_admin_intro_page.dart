import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/enums/app_page.dart';

import '../blocs/user_admin_intro_bloc.dart';
import '../blocs/validator.dart';
import '../enums/form_status.dart';
import '../widgets/form_text_field.dart';
import 'package:image_picker/image_picker.dart';

class UserAdminIntroPage extends StatelessWidget with Validator {
  const UserAdminIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('initialConfigurationTitle'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<UserAdminIntroCubit, UserAdminIntroUpdate>(
          listener: (BuildContext context, UserAdminIntroUpdate state) async { 
            if(state.status == FormStatus.success) context.goNamed(AppPage.home.name);
            if (state.status == FormStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:  Text(state.errorMessage==null? 'error'.tr():'error'.tr(args:  [state.errorMessage??""])),
                    ),
                  );
              }
            if (state.verificationMailSent){
              ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:  Text("emailverificationSentMessage".tr()),
                    ),
                  );
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // Use Expanded to take available space
                  child: PageView(
                    controller:context.read<UserAdminIntroCubit>().pageController,
                    onPageChanged: (int page) =>context.read<UserAdminIntroCubit>().updateCurrentPage(page),
                    children: [
                      if(context.read<UserAdminIntroCubit>().authService.currentAuthUser?.emailVerified == false)
                      _emailVerificationPage(context),
                      _workplaceLogoTypePage(context),
                      _workplaceActivityTypePage(context),
                      _addLocationsPage(context),
                      _finalMessagePage(context),
                      // Add more pages as needed
                    ],
                  ),
                ),
                if(context.read<UserAdminIntroCubit>().state.showNavButtons)
                Row(
                  // Row for navigation buttons
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      
                      onPressed: 
                        context.read<UserAdminIntroCubit>().state.currentPage ==0 ||
                        context.read<UserAdminIntroCubit>().state.status == FormStatus.inProgress
                          ? null
                          : () {
                              context
                                  .read<UserAdminIntroCubit>()
                                  .pageController
                                  .previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                            },
                      child: const Text('Previous'),
                    ),
                    ElevatedButton(
                      onPressed: 
                        context.read<UserAdminIntroCubit>().state.status == FormStatus.inProgress ||
                        context.read<UserAdminIntroCubit>().state.workplaceActivityType.isEmpty
                          ? null
                          :
                        context.read<UserAdminIntroCubit>().state.currentPage ==3 // Index of the last page
                          ? () async {
                              // Save configuration data and navigate to home
                              // ... your saving logic
                              await context.read<UserAdminIntroCubit>().saveConfigurations();
                            }
                          : () {
                              context
                                  .read<UserAdminIntroCubit>()
                                  .pageController
                                  .nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                            },
                      child: context
                                  .read<UserAdminIntroCubit>()
                                  .state
                                  .currentPage ==
                              3
                          ? const Text('Finish')
                          : const Text(
                              'Next'), // Change button text on last page
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _emailVerificationPage(BuildContext context) {
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 30,
            children: [
              Text("emailverificationMessage".tr()),
              ElevatedButton(
                  onPressed: context.read<UserAdminIntroCubit>().resendVerificationEmail,
                  child: Text("emailverificationLabel".tr())
              ),
            ],
          ),
    );
  }

    Widget _workplaceLogoTypePage(BuildContext context) {
    return BlocBuilder<UserAdminIntroCubit, UserAdminIntroUpdate>(
      builder: (context, state) {
        return Column(
          children: [
            if (state.selectedLogo != null)
              Image.file(
                state.selectedLogo!,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 150,
                width: 150,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, size: 50)),
              ),
            // Button to pick the image
            ElevatedButton(
              onPressed: () => context.read<UserAdminIntroCubit>().pickImage(
                imageSource : ImageSource.gallery,
              ),
              child: Text('selectLogo'.tr()),
            ),
            Center(child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'workplaceLogoMainMessage'.tr(),
                maxLines: 5,
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _workplaceActivityTypePage(BuildContext context) {
    return BlocBuilder<UserAdminIntroCubit, UserAdminIntroUpdate>(
      builder: (context, state) {
        return Column(
          children: [
            FormTextField(
              validator: validateName,
              labelText: 'workplaceActivityLabel'.tr(),
              hintText: 'workplaceActivityMessage'.tr(),
              prefix: const Icon(Icons.business),
              keyboardType: TextInputType.name,
              onChanged: (value) => context.read<UserAdminIntroCubit>().updateWorkplaceActivity(value),
            ),
            Center(child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'workplaceDescriptionMainMessage'.tr(),
                maxLines: 5,
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _addLocationsPage(BuildContext context) {
    return BlocBuilder<UserAdminIntroCubit, UserAdminIntroUpdate>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              // Row for text field and button
              children: [
                Expanded(
                  child: 
                  FormTextField(
                    controller:context.read<UserAdminIntroCubit>().itemController,
                    validator: validateName,
                    labelText: 'locationText'.tr(),
                    hintText: 'locationMessage'.tr(),
                    prefix: const Icon(Icons.add_location),
                  )
                ),
                IconButton(
                  onPressed: () {
                    if (context.read<UserAdminIntroCubit>().itemController.text.isNotEmpty) {
                      context.read<UserAdminIntroCubit>().addLocation(context.read<UserAdminIntroCubit>().itemController.text);
                      context.read<UserAdminIntroCubit>().itemController.clear(); 
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Center(child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'workplaceLocationMainMessage'.tr(),
                maxLines: 5,
              ),
            )),
            Expanded(
              // Expanded to take up available space
              child: ListView.builder(
                itemCount:context.read<UserAdminIntroCubit>().state.locations.length,
                itemBuilder: (context, index) {
                  final item = context.read<UserAdminIntroCubit>().state.locations[index];
                  return ListTile(
                    title: Text(item),
                    trailing: IconButton(
                      onPressed: () {
                        context.read<UserAdminIntroCubit>().removeLocation(index);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _finalMessagePage(BuildContext context) {
    return Center(child: 
    Text('letsGoMessage'.tr(),
    style: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
    ));
  }
}
