import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/enums/app_page.dart';

import '../blocs/user_intro_bloc.dart';
import '../blocs/validator.dart';
import '../enums/form_status.dart';

class UserIntroPage extends StatelessWidget with Validator {
  const UserIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('initialConfigurationTitle'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<UserIntroCubit, UserIntroUpdate>(
          listener: (BuildContext context, UserIntroUpdate state) async { 
            if(state.status == FormStatus.success){
                    context.goNamed(AppPage.home.name);
                  }
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  // Use Expanded to take available space
                  child: PageView(
                    controller:
                        context.read<UserIntroCubit>().pageController,
                    onPageChanged: (int page) {
                      context
                          .read<UserIntroCubit>()
                          .updateCurrentPage(page);
                    },
                    children: [
                      _finalMessagePage(context),
                      // Add more pages as needed
                    ],
                  ),
                ),
                Row(
                  // Row for navigation buttons
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: context
                                  .read<UserIntroCubit>()
                                  .state
                                  .currentPage ==
                              0
                          ? null
                          : () {
                              context
                                  .read<UserIntroCubit>()
                                  .pageController
                                  .previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                            },
                      child: const Text('Previous'),
                    ),
                    ElevatedButton(
                      onPressed: context
                                  .read<UserIntroCubit>()
                                  .state
                                  .currentPage ==
                              2 // Index of the last page
                          ? () async {
                              // Save configuration data and navigate to home
                              // ... your saving logic
                              await context.read<UserIntroCubit>().saveConfigurations();
                            }
                          : () {
                              context
                                  .read<UserIntroCubit>()
                                  .pageController
                                  .nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                            },
                      child: context
                                  .read<UserIntroCubit>()
                                  .state
                                  .currentPage ==
                              2
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

  Widget _finalMessagePage(BuildContext context) {
    return Center(child: 
    Text('letsGoMessage'.tr()
    ));
  }
}
