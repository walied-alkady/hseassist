import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/enums/provider_type.dart';
import 'package:hseassist/utilities/extension_methods.dart';
import '../blocs/login_bloc.dart';
import '../enums/app_page.dart';
import '../enums/form_status.dart';
import '../enums/login_route.dart';
import '../models/workplace.dart';
import '../widgets/form_button.dart';
import '../widgets/form_text_field.dart';
import '../widgets/hse_assist_logo.dart';

class LoginPage extends StatelessWidget{
  LoginPage({super.key});
  // final emailController = TextEditingController();
  // final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final loginCubit = context.read<LoginCubit>();
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('login'.tr()),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BlocConsumer<LoginCubit, LoginFormUpdate>(
                bloc: loginCubit,
                listener: (BuildContext context, LoginFormUpdate state) async {  
                  if (state.status == FormStatus.failure) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage==null? 'error'.tr():'error'.tr(args:  [state.errorMessage??""])),
                        ),
                      );
                      Future.delayed(const Duration(seconds: 2), () {  loginCubit.reset(); });
                  }
                  // if(state.status == FormStatus.success){
                  //   context.goNamed(AppPage.home.name);
                  // }
                  if(state.reRouteState == LoginRoute.goFirstUserLogin){
                    context.goNamed(AppPage.userAdminIntro.name);
                  }
                  if(state.reRouteState == LoginRoute.goRegister){
                    context.goNamed(AppPage.register.name);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text("registerCompleteData".tr()),
                        ),
                      );
                  }
                  if(state.reRouteState == LoginRoute .noCurrentWorkplace){
                    await _showWorkplaceSlectionDialog(context);
                    // if(loginCubit.currentUser.currentWorkplace!.isNotEmpty && context.mounted){
                    //     context.goNamed(AppPage.home.name);
                    // }else{
                    //     if(context.mounted){
                    //       await _showDialog(context,
                    //       title: "selectWorkplaceTitle".tr() ,
                    //       contentMain: "workplaceNotFoundMessage".tr()
                    //       );
                    //     }
                    //     Future.delayed(const Duration(seconds: 2), () {  loginCubit.reset(); });
                    // }
                  }
                  if(state.reRouteState == LoginRoute .noInvitation && context.mounted){
                    await _showDialog(context,
                    title: "invitationRequiredTitle".tr(),
                    contentMain: 'invitationRequiredMessage'.tr(),
                    contentSecondary: "invitationRequiredMessageSecondary".tr(),
                    );
                    Future.delayed(const Duration(seconds: 2), () {  loginCubit.reset(); });
                  }
                },
                builder: (context,state) {
                  if (state.status == FormStatus.success) {
                    Future.microtask(() => context.goNamed(AppPage.home.name)); // Navigate after the frame is built
                    return HseAssistLogo(); // Still show the logo while navigating
                  }
                  
                  if(state.reRouteState == LoginRoute.noCurrentWorkplace && loginCubit.currentUser.currentWorkplace!.isNotEmpty){
                    Future.microtask(() => context.goNamed(AppPage.home.name));
                    return HseAssistLogo();
                  }
                  if (state.status == FormStatus.inProgress || state.reRouteState == LoginRoute.goHome){
                    return HseAssistLogo();
                  } else {
                    return loginForm(context);
                  }
                } ),
              ])
            ),        
              ),
          );
  }

  Widget loginForm(BuildContext context) {
    final LoginCubit cubit = context.read<LoginCubit>();
    return Form(
            key: _formKey,
            autovalidateMode: cubit.state.autovalidateMode,
            child: Column(
              spacing : 8,
              children: [
              //Email  
              FormTextField(
                    enabled: context.read<LoginCubit>().state.status != FormStatus.inProgress,
                    labelText: context.locale == const Locale('en', 'US')? 'email'.tr().capitalizeFirstLetter():'email'.tr(),
                    hintText: "enterEmail".tr(),
                    prefix: const Icon(Icons.email),
                    validator: cubit.validateEmail,
                    onChanged: cubit.updateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
              //password
              FormTextField(
                enabled: context.read<LoginCubit>().state.status != FormStatus.inProgress,
                labelText: 'password'.tr(),
                hintText: "enterPassword".tr(),
                validator: cubit.validatePassword,
                onChanged: cubit.updatePassword,
                obscureText: cubit.state.obscureText,
                keyboardType: TextInputType.visiblePassword,
                prefix: const Icon(Icons.lock),
                suffix: IconButton(onPressed: cubit.toggleObscureText, icon: const Icon(Icons.remove_red_eye)),
              ),
              //forget pass
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TextButton(
                    onPressed: ()=> 
                    cubit.state.status == FormStatus.inProgress?
                    null
                    :
                    context.goNamed(AppPage.forgotPassword.name),
                    child: Text(
                      "forgotPassword".tr(),
                      style: const TextStyle(
                          color: Colors.black,
                          decorationColor: Colors.black,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              // login
              FormButton(
                buttonText: 'login'.tr(),
                onPressed: (context.read<LoginCubit>().state.status == FormStatus.inProgress) ? null: () async {
                    //context.goNamed(AppPage.home.name);
                    //TODO; for test bypass login
                    //return;
                    if (_formKey.currentState!.validate()) {
                      //emailController.text = cubit.state.email;
                      await cubit.login();
                      
                    } else {
                      // in case a user has submitted invalid form we'll set 
                      // AutovalidateMode.always which will rebuild the form
                      // in result we'll start getting error message
                      cubit.updateAutovalidateMode(AutovalidateMode.always);
                    }
                  }
              ),
              // login google
              FormButton(
                buttonText: 'google'.tr(),
                onPressed: (context.read<LoginCubit>().state.status == FormStatus.inProgress) ? null:() async {
                    await cubit.login(provider: ProviderType.google);
                  }
              ),
              // register
              Center(
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("registerMessage".tr()),
                  ),
                  TextButton(
                    onPressed: (context.read<LoginCubit>().state.status == FormStatus.inProgress) ? null:()=> cubit.state.status==FormStatus.inProgress?null: context.goNamed(AppPage.register.name),
                    child: Text(
                      "register".tr(),
                      style: const TextStyle(
                          color: Colors.black,
                          decorationColor: Colors.black,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ))
                ],),
              ), 
              if(cubit.state.status == FormStatus.inProgress)
              const CircularProgressIndicator(),
              // language
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  //width: double.infinity, // Full width
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton<Locale>(
                            value: context.locale,
                            
                            onChanged: (Locale? newLocale) {
                              if (newLocale != null) {
                                context.setLocale(newLocale);
                                cubit.updateLanguage(newLocale);
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: Locale('en', 'US'),
                                enabled: context.read<LoginCubit>().state.status != FormStatus.inProgress,
                                child: Text('languageSelection.en'.tr()),
                              ),
                              DropdownMenuItem(
                                value: Locale('ar', 'EG'),
                                enabled: context.read<LoginCubit>().state.status != FormStatus.inProgress,
                                child: Text('languageSelection.ar'.tr()),
                              ),
                            ],
                          )
  ,
                  ),
                ),
              )
              
          ])
        );
  }
  
  Widget _hseAssistLogo(){
    return  TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 3),
      builder: (BuildContext context, double opacity, Widget? child) {
        return Opacity(
          opacity: opacity,
          child: Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    width: 150,
                  )
        );
      },
    );
  }

  Future<void> _showDialog(BuildContext context,{
    required String title,
    required String contentMain,
    String contentSecondary='',
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(contentMain),
                Text(contentSecondary),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ok'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _showWorkplaceSlectionDialog(BuildContext context) async {
    final LoginCubit _loginCubit = context.read<LoginCubit>();
    Workplace? wp;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("selectWorkplaceTitle".tr()),
          content: SingleChildScrollView(
            child: DropdownMenu<Workplace>(
                                selectedTrailingIcon: const Icon(
                                  Icons.keyboard_arrow_up_sharp,
                                  size: 20
                                ),
                                inputDecorationTheme: InputDecorationTheme(
                                  filled: false,
                                  fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,//Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                      width: 0.6
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(1),
                                      width: 0.6
                                    ),
                                  )
                                ),
                                expandedInsets: EdgeInsets.zero,
                                label: Text('locationText'.tr()),
                                leadingIcon: const Icon(Icons.location_searching),
                                onSelected: (Workplace? value) {
                                  // This is called when the user selects an item.
                                  if(value!=null){
                                    //_loginCubit.updateCurrentWorkplace(value);
                                    wp  = value;
                                  } 
                                },
                                searchCallback: (List<DropdownMenuEntry<Workplace?>> entries, String query) {
                                  return entries.indexWhere((e) => 
                                  (
                                    e.value!.description.contains(query)) 
                                  );
                                },
                                dropdownMenuEntries: _loginCubit.joinedWorkplaces.map<DropdownMenuEntry<Workplace>>((Workplace loc) {
                                  return DropdownMenuEntry<Workplace>(
                                  trailingIcon: const Icon(
                                    Icons.keyboard_arrow_down_sharp,
                                    size: 20,
                                  ),
                                  label: _loginCubit.joinedWorkplaces.first.description,
                                  labelWidget: Text(loc.description),
                                  value: loc,);
                                  }).toList()
                            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ok'.tr()),
              onPressed: () async {
                if(wp != null){
                  await _loginCubit.selectWorkplace(wp!);
                }
                
                if(context.mounted){
                  Navigator.of(context).pop();
                }
                
              },
            ),
          ],
        );
      },
    );
  }
}
// walied.alkady@gmail.com	
//2 
