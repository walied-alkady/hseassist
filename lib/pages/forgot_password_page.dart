import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/enums/form_status.dart';
import '../blocs/forgot_password_bloc.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordFormUpdate>(
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage==null? 'error'.tr():'error'.tr(args:  [state.errorMessage??""])),
              ),
            );
        }
        if (state.status.isSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("checkMailSnackbarMessage".tr()),
              ),
            );
            Navigator.pop(context);
          //context.read<ForgotPasswordBloc>().add(const ResetStateForgotPasswordEvent());
          // Navigate back to login
          // context.goNamed(AppPage.login.name);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("forgotPassword".tr()),
        ),
        body: Form(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    
                    labelText: 'email'.tr(),
                  ),
                  onChanged: (email) => context.read<ForgotPasswordCubit>().updateEmail(email),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "enterEmail.tr()";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<ForgotPasswordCubit, ForgotPasswordFormUpdate>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.status.isInProgress 
                          ? null
                          : () {
                              context.read<ForgotPasswordCubit>().submit();
                            },
                      child: Text("resetPassword".tr()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
