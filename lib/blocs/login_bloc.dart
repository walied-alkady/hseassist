import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/blocs/validator.dart';
import 'package:hseassist/enums/mini_session_target_type.dart';
import 'package:hseassist/models/hse_hazard.dart';
import 'package:hseassist/models/hse_task.dart';
import '../Exceptions/authentication_exception.dart';
import '../Exceptions/database_exception.dart';
import '../enums/form_status.dart';
import '../enums/login_route.dart';
import '../enums/provider_type.dart';
import '../enums/query_operator.dart';
import '../models/auth_user.dart';
import '../models/mini_session.dart';
import '../models/user_session.dart';
import '../models/user_workplace.dart';
import '../models/workplace.dart';
import '../models/workplace_invitation.dart';
import '../models/workplace_settings.dart';
import '../repository/logging_reprository.dart';
import '../service/preferences_service.dart';
import 'manager.dart';

class LoginFormUpdate extends Equatable {
  final AutovalidateMode autovalidateMode;
  final String email;
  final String password;
  final String confirmPassword;
  final bool obscureText;
  final FormStatus status;
  final LoginRoute reRouteState;
  final String? errorMessage;
  
  const LoginFormUpdate({
    this.autovalidateMode = AutovalidateMode.disabled,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.obscureText = true,
    this.reRouteState = LoginRoute.none,
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  LoginFormUpdate  copyWith({
    AutovalidateMode? autovalidateMode,
    String? email,
    String? password,
    String? confirmPassword,
    bool? obscureText,
    LoginRoute? reRouteState,
    FormStatus? status,
    String? errorMessage,
  }) {
    return LoginFormUpdate(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      email: email ?? this.email,
      password: password ?? this.password,
      obscureText: obscureText ?? this.obscureText,
      reRouteState: reRouteState ?? this.reRouteState,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    
    );
  }
  
  @override
  List<Object?> get props => [
        email,
        password,
        obscureText,
        reRouteState,
        autovalidateMode,
        confirmPassword,
        status,
        errorMessage,
      ];
}

class LoginCubit extends Cubit<LoginFormUpdate> with Validator,Manager<LoginCubit> {

  late final AuthUser currentUser;
  late final User? usr;
  
  Map<String,String> language ={LanguageCodes.enUS:'English',LanguageCodes.arEG:'عربى'};
  WorkplaceInvitation? newInvitaiton;  
  List<Workplace> joinedWorkplaces = [];
  final _log = LoggerReprository('LoginCubit');

  LoginCubit() : super(const LoginFormUpdate());
  
  void initForm() async {
    try{
      _log.i('loading ...');
      final isUserToken = await authService.isUserLoggedIn();
      if(isUserToken){
        loggedIn();
        return;
      }
    }catch(e){
      _log.i('Loading error...');
      emit(state.copyWith(status: FormStatus.failure, errorMessage: e.toString()));
      rethrow; 
    }finally{
      if (state.status != FormStatus.failure) { // Only if initForm was successful
          emit(state.copyWith(status: FormStatus.initial)); // Indicate loading complete
      }
      _log.i('Form initialized...');
    }

  }
  
  Future<List<Workplace>> getJoinedWorkplaces() async {
    try {
      final joinedPlaces =await db.findAll<UserWorkplace>(
        query: 'userId',
        quaryOperator: QueryComparisonOperator.eq,
        queryValue: prefs.currentUserId      
      );

      if (joinedPlaces.isEmpty) {
        return []; 
      }

      List<Workplace> workplaces = [];
      for (var workplaceData in joinedPlaces) {
          final workplace = await db.findOne<Workplace>(workplaceData.workpalceId); // Assuming 'id' is the field in Workplace
          if (workplace != null) {
            workplaces.add(workplace);
          }
      }
      return workplaces;
    } catch (e) {
      _log.e('Error fetching joined workplaces: $e');
      return []; // Return empty list on error
    }
  }

  Future<void> updateCurrentWorkplace(String workplaceId) async {
    try{
      _log.i('updateing current workplace to user...');
    final joinedPlaces = await db.findAll<UserWorkplace>(
        query: 'userId',
        quaryOperator: QueryComparisonOperator.eq,
        queryValue: currentUser.id,
      );
    final currentWorkPlaceUserData = joinedPlaces.where((user)=> user.workpalceId == workplaceId).first;  
    await db.updateOne<AuthUser>(currentUser.id, {
      AuthUserFields.currentWorkplace.name: workplaceId,
      AuthUserFields.currentWorkplaceDataId.name: currentWorkPlaceUserData.id,
      AuthUserFields.currentWorkplaceRole.name: currentWorkPlaceUserData.role,
      });
    _log.i('saved...');
    }on Exception catch (e) {
    _log.e('$e');
    emit(
      state.copyWith(
        errorMessage: e.toString(),
        status: FormStatus.failure,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {  emit( state.copyWith(status: FormStatus.initial,)); });
  }
  }

  void updateEmail(String? email) {
    emit(state.copyWith(email: email));
  }

  void updatePassword(String? password) {
    emit(state.copyWith(password: password));
  }

  void updateConfirmPassword(String? confirmPassword) {
    emit(state.copyWith(confirmPassword: confirmPassword));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  void toggleObscureText() {
    emit(state.copyWith(obscureText: !state.obscureText));
  }

  void reset() {
    emit(const LoginFormUpdate());
  }
  
  Future<void> login({provider=ProviderType.password}) async {
  
  emit(state.copyWith(status: FormStatus.inProgress));
  try {
      _log.i('Authorizing user by password...');
      if(provider == ProviderType.password) {
          usr = await authService.logIn(
          email: state.email,
          password: state.password,
          provider: ProviderType.password
        );
      }else{
        usr = await authService.logIn(
          email: state.email,
          password: state.password,
          provider: ProviderType.google
        );
      }
      if(usr==null) {
        _log.i('could not be authorized...');
        throw UserNotFoundFailure();   
      }else{
        _log.i('Authorized by password...');
        final authUser = (await db.findOneByField<AuthUser>('email',usr?.email));
        if(authUser == null) throw UserNotFoundFailure();
        currentUser = authUser;
        _log.i('loading joined workplaces...');
        final joinedPlaces =await db.findAll<UserWorkplace>(
        query: 'userId',
        quaryOperator: QueryComparisonOperator.eq,
        queryValue: currentUser.id
        );
        if(joinedPlaces.isEmpty) {
          _log.i('joined workplaces is empty...');
          emit(
            state.copyWith(
              reRouteState: LoginRoute.noInvitation,
            ),
          );
          return;
        } else {
          final currentWorkplace = currentUser.currentWorkplace??"";
          if(currentWorkplace.isNotEmpty) {
            await updateCurrentWorkplace(currentWorkplace);
          }else{
            emit(
              state.copyWith(
                reRouteState: LoginRoute.noCurrentWorkplace,
              ),
            );
            return;
          }
        }
        _log.i('finding loading user data...');
        _loadUserData(usr!,provider:ProviderType.password);
      }
  }
  on AuthenticationFailure catch (e) {
    _log.e('$e');
    emit(
      state.copyWith(
        errorMessage: e.message,
        status: FormStatus.failure,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {  emit( state.copyWith(status: FormStatus.initial,)); });
  }
  on DatabaseFailure catch (e) {
    _log.e('$e');
    emit(
      state.copyWith(
        errorMessage: e.message,
        status: FormStatus.failure,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {  emit( state.copyWith(status: FormStatus.initial,)); });
  } 
  on Exception catch (e) {
    _log.e('$e');
    emit(
      state.copyWith(
        errorMessage: e.toString(),
        status: FormStatus.failure,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {  emit( state.copyWith(status: FormStatus.initial,)); });
  }

}
  
  Future<void> loggedIn() async{
    if (db.currentUser == null) return;
    await prefs.setUserJustLoggedIn();
    _log.i('updateing lists...');
    final jw = await getJoinedWorkplaces();
    if(jw.isNotEmpty) joinedWorkplaces.addAll(jw);
    if(db.currentUser!.currentWorkplace!.isNotEmpty){
      await initGeminiService();
      emit(state.copyWith(status: FormStatus.success, reRouteState: LoginRoute.goHome));
    }else if(joinedWorkplaces.isEmpty) {
      emit(state.copyWith(reRouteState: LoginRoute.noInvitation));
      return;
    }else if(joinedWorkplaces.isNotEmpty){
      final joinedPlaces =await db.findAll<UserWorkplace>(
      query: 'userId',
      quaryOperator: QueryComparisonOperator.eq,
      queryValue: prefs.currentUserId      
    );

    if(joinedPlaces.isNotEmpty && joinedPlaces.length==1 && joinedPlaces.first.role == 'admin'){
        await updateCurrentWorkplace(joinedWorkplaces.first.id);
        await initGeminiService();
        emit(state.copyWith(status: FormStatus.success,reRouteState: LoginRoute.goHome));
      }else{
        emit(state.copyWith(reRouteState: LoginRoute.noCurrentWorkplace));
        return;
      } 
    }
  }

  Future<void> _loadUserData(User usr,{ProviderType provider=ProviderType.password}) async{
    _log.i('finding user in database...');
      final savedAuthUser = await db.findOneByField<AuthUser>('email',usr.email);
      db.currentUser = savedAuthUser;
      if(savedAuthUser==null && provider == ProviderType.google){
        _log.i('not found in db creating user...');  
        final newUser = AuthUser(
          id: '', 
          email: usr.email!, 
          firstName: usr.displayName?.split(" ")[0] ?? '',
          lastName: usr.displayName?.split(" ").sublist(1).join(" ") ?? '',
          uid: usr.uid, 
          provider: ProviderType.google.name,
          isFirstLogin: true,
          );
        await db.create<AuthUser>(newUser);
        _log.i('saving user data locally...');  
        await prefs.setCurrentUserId(newUser.id);
      }else if(savedAuthUser==null && usr.email!=null && provider == ProviderType.password ){
        emit(state.copyWith(reRouteState: LoginRoute.goRegister));
        return;
      }
      if (savedAuthUser == null) throw UserNotFoundFailure();
      _log.i('Authorized ${savedAuthUser.email} saving user data...');
      final token = await usr.getIdToken(); // Get Firebase ID token
      if (token !=null) await prefs.writeSecure(key: 'authToken', value: token);
      await prefs.setUserJustLoggedIn(); 
      _log.i('checking if admin first time login...');
      db.currentWorkplaceId = savedAuthUser.currentWorkplace;
      bool isFirstUserOverall = await _checkIfFirstLocationUser();
      if (isFirstUserOverall && savedAuthUser.isFirstLogin) {
        // First time login and first user overall - start configuration
        prefs.setIsFirstLogin(false); // Set to false after configuration
        final currentWorkplace = await db.findOneByField<UserWorkplace>('userId',savedAuthUser.id);
        db.currentWorkplaceId = currentWorkplace?.workpalceId;
        db.currentRole = currentWorkplace?.role;
        await db.updateOne<AuthUser>(savedAuthUser.id,{
          AuthUserFields.currentWorkplace.name:currentWorkplace?.workpalceId??"",
          AuthUserFields.isFirstLogin.name:false,
          });
        emit(state.copyWith(reRouteState: LoginRoute.goFirstUserLogin));
        return;
      }else if(savedAuthUser.isFirstLogin){
        prefs.setIsFirstLogin(false); // Set to false after configuration
        final currentWorkplace = await db.findOneByField<UserWorkplace>('userId',savedAuthUser.id);
        db.currentWorkplaceId = currentWorkplace?.workpalceId;
        db.currentRole = currentWorkplace?.role;
        await db.updateOne<AuthUser>(savedAuthUser.id,{
          AuthUserFields.currentWorkplace.name:currentWorkplace?.workpalceId??"",
          AuthUserFields.isFirstLogin.name:false,
          });
        emit(state.copyWith(reRouteState: LoginRoute.goFirstLogin));
        return;
      }
      _log.i('updateing miniSessions...');
      //final tasks = await db.findAll<HseTask>(query: 'responsibleId',quaryOperator: QueryOperator.isEqualTo,queryValue:currenUser?.id);
      final hazards = await db.findAll<HseHazard>(query: 'createdById',quaryOperator: QueryComparisonOperator.eq,queryValue:prefs.currentUserId);
      final thisMonthHazards = hazards.where((hazard) => hazard.createdAt?.month  == DateTime.now().month).length;
      final currentWorkplaceSettings = await db.findAll<WorkplaceSetting>().then(
        (list) => list.firstOrNull
      );
      if (thisMonthHazards <= (currentWorkplaceSettings?.targetHazardIdsPerYear??0/12)){
        _log.i('loading availableSessions...');
        if(savedAuthUser.assignedMiniSessions?.isNotEmpty??false){
        final availableSessions = await db.findAll<MiniSession>(query: 'id' ,quaryOperator: QueryComparisonOperator.ninArr,queryValue: savedAuthUser.assignedMiniSessions);
        _log.i('got ${availableSessions.length}  availableSessions...');
        _log.i('loading selectedTarget...');
        final selectedTarget = availableSessions.where((test)=> test.targetType == MinisessionTrgetType.hazardId.name).first;
        _log.i('got selected target, saving to user...');
        savedAuthUser.assignedMiniSessions?.add(selectedTarget.id);
        _log.i('saved mini session to user...');
        }else{
          _log.i('no available miniSession to be added to user...');
        }
      }
      _log.i('updateing lists...');
      final jw = await getJoinedWorkplaces();
      if(jw.isNotEmpty) joinedWorkplaces.addAll(jw);

      if(
        savedAuthUser.currentWorkplace!= null && savedAuthUser.currentWorkplace!.isNotEmpty){
        await initGeminiService();
        emit(state.copyWith(status: FormStatus.success, reRouteState: LoginRoute.goHome));
      }else if(joinedWorkplaces.isEmpty) {
        emit(state.copyWith(reRouteState: LoginRoute.noInvitation));
        return;
      }else if(joinedWorkplaces.isNotEmpty){
        final joinedPlaces =await db.findAll<UserWorkplace>(
        query: 'userId',
        quaryOperator: QueryComparisonOperator.eq,
        queryValue: prefs.currentUserId      
      );

      if(joinedPlaces.isNotEmpty && joinedPlaces.length==1 && joinedPlaces.first.role == 'admin'){
          await updateCurrentWorkplace(joinedWorkplaces.first.id);
          await initGeminiService();
          emit(state.copyWith(status: FormStatus.success,reRouteState: LoginRoute.goHome));
        }else{
          emit(state.copyWith(reRouteState: LoginRoute.noCurrentWorkplace));
          return;
        } 
      }
  }
  
  Future<bool> _checkIfFirstLocationUser() async {
    int userCount = await db.findAll<AuthUser>().then((usrs) => usrs.length);
    return userCount == 1;
  }
  
  Future<void> selectWorkplace(Workplace workplace) async {
    await updateCurrentWorkplace(workplace.id);
    _log.i('finding loading user data...');
    final currentAuth = authService.currentAuthUser;
    if(currentAuth==null) throw UserNotFoundFailure();
    await _loadUserData(currentAuth,provider:ProviderType.password);
    emit(state.copyWith(status: FormStatus.success, reRouteState: LoginRoute.goHome));
  }

  Future<void> forgetPassword() async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
        //await authService.resetPass(); 
        //emit(state.copyWith(loginState: LoginRoute.resetPassDone));
    } 
    on Exception catch (e) {
        _log.e('$e');
        emit(state.copyWith(status: FormStatus.failure,errorMessage: e.toString()));
    }
  }

  Future<void> updateLanguage(Locale newLocale) async {
    await prefs.setlanguage(newLocale.languageCode);
  }
  
}