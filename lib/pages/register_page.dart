import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/register_bloc.dart';
import '../blocs/validator.dart';
import '../enums/form_status.dart';
import '../widgets/form_text_field.dart';

class RegisterPage extends StatelessWidget with Validator{
  RegisterPage({super.key});
  
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final RegisterCubit _registerCubit = context.read<RegisterCubit>();
    _registerCubit.initForm();
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('registerTitle'.tr()),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BlocConsumer<RegisterCubit, RegisterFormUpdate>(
                bloc: _registerCubit,
                listener: (BuildContext context, RegisterFormUpdate state) {  
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
                          content: Text('successSnackbarMessage'.tr()),
                        ),
                      );
                    context.pop();  
                  }
                  
                },
                builder: (context, state) {
                  return registerForm(context);
                })
              ])
            ),        
              ),
          );
  }
  
  Form registerForm(BuildContext context) {
    final RegisterCubit registerCubit = context.read<RegisterCubit>();
    emailController.text = registerCubit.state.email;
    return Form(
            key: _formKey,
            autovalidateMode: registerCubit.state.autovalidateMode,
            child: Column(
              children: [
              //Email  
              FormTextField(
              controller: emailController,  
                  validator: validateEmail,
                  enabled: registerCubit.state.enableEmail,
                  onChanged: registerCubit.updateEmail,
                  keyboardType: TextInputType.emailAddress,
                  labelText: 'email'.tr(),
                  hintText: registerCubit.state.enableEmail?
                    'email'.tr()
                    :
                    registerCubit.state.email,
                ),
              const SizedBox(height: 8.0),
              //password
              if(registerCubit.state.enableEmail)
              TextFormField(
                validator: validatePassword,
                onChanged: registerCubit.updatePassword,
                obscureText: registerCubit.state.obscureText,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: 'password'.tr(),
                  hintText: "enterPassword".tr(),
                  suffixIcon: IconButton(onPressed: registerCubit.toggleObscureText, icon: const Icon(Icons.remove_red_eye)),
                  border: const OutlineInputBorder(),
                ),
              ),
              if(registerCubit.state.enableEmail)
              const SizedBox(height: 8.0),
              if(registerCubit.state.enableEmail)
              TextFormField(
                validator: (value) =>
                    validateConfirmPassword(
                      value,
                      registerCubit.state.password,
                    ),
                obscureText: registerCubit.state.obscureText,
                keyboardType: TextInputType.visiblePassword,
                onChanged: registerCubit.updateConfirmPassword,
                decoration: InputDecoration(
                  labelText: "confirmPassword".tr(),
                  hintText: "ConfirmPasswordMessage".tr(),
                  border: const OutlineInputBorder(),
                ),
              ),
              if(registerCubit.state.enableEmail)
              const SizedBox(height: 8.0),
              //first name  
              TextFormField(
                    validator: validateName,
                    onChanged: registerCubit.updateFirstName,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: 'firstNamelabel'.tr(),
                      hintText: "firstNameMessage".tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
              const SizedBox(height: 8.0),
              //last name  
              TextFormField(
                validator: validateName,
                onChanged: registerCubit.updateLastName,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'lastNamelabel'.tr(),
                  hintText: "lastNameMessage".tr(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8.0),
              ///Is new organization
              Row(
                children: [
                  Expanded( // Wrap the icon and text in an Expanded
                    child: Row(
                      children: [
                        const SizedBox(width: 6.0),
                        Text("isNewWorkplaceLabel".tr()),
                      ],
                    ),
                  ),
                  Switch(
                    value: registerCubit.state.isNewWorkplace,
                    onChanged: (value) {
                      registerCubit.toggleIsNewWorkplace();
                    }
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Offstage(
                offstage: !registerCubit.state.isNewWorkplace,
                child: TextFormField(
                  validator: registerCubit.state.isNewWorkplace?validateName:null,
                  keyboardType: TextInputType.name,
                  onChanged: registerCubit.updateWorkplaceName,
                  decoration: InputDecoration(
                    labelText: 'workplace'.tr(),
                    hintText: "workplaceMessage".tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              //ok
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed:(registerCubit.state.status == FormStatus.inProgress)?null: (){
                    if (_formKey.currentState!.validate()) {
                      registerCubit.register(context);
                    } else {
                      // in case a user has submitted invalid form we'll set 
                      // AutovalidateMode.always which will rebuild the form
                      // in result we'll start getting error message
                      registerCubit.updateAutovalidateMode(AutovalidateMode.always);
                    }
                  },
                  child: Text('ok'.tr()),
                ),
              ),
          ])
          );
  }
}


// jsmith@@example.com
