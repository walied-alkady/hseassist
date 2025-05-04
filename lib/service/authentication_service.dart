import 'package:firebase_auth/firebase_auth.dart';
import 'package:hseassist/service/preferences_service.dart';
import '../Exceptions/authentication_exception.dart';
import '../enums/authentication status.dart';
import '../enums/provider_type.dart';
import '../repository/authentication_repository.dart';
import '../repository/logging_reprository.dart';

class AuthenticationService  {
  /// {@macro authentication_service}
  /// 
  AuthenticationService(this.prefs,{this.withEmulator = false}) ;
    
  late final AuthenticationRepository _firebaseAuth = withEmulator?(AuthenticationRepository()..initEmulator()):AuthenticationRepository();
  final _log = LoggerReprository('AuthenticationService');
  final bool withEmulator;
  final PreferencesService prefs;
  
  User? get currentAuthUser {
    return _firebaseAuth.firebaseAuth.currentUser;
  }

  AuthenticationStatus get userAuthStatus {
    if(_firebaseAuth.firebaseAuth.currentUser !=null || _firebaseAuth.firebaseAuth.currentUser !=null){
      return AuthenticationStatus.authenticated;
    }else{
      return AuthenticationStatus.unauthenticated;
    }
  }
  
  Future<void> reloadeUser() async {
    await _firebaseAuth.firebaseAuth.currentUser?.reload();
  }

  Future<User?> register(
      {String? email,
      String? password,
      required ProviderType provider}) async {
    try {
      UserCredential? userCredential;
      if (provider == ProviderType.password) {
        if (email != null && password != null) {
          userCredential = await _firebaseAuth.signUp(
              email: email, password: password);
        } else {
          throw ArgumentError("Email and password are required for password registration.");
        }
      } else if (provider == ProviderType.google) {
        userCredential = await _firebaseAuth.logInWithGoogle();
      } else {
        throw UnsupportedError("Provider $provider is not supported for registration.");
      }

      if (userCredential?.user != null) {
          return userCredential!.user;
      } else {
          return null;
      }
    } catch (e) {
      _log.e("Registration Error: $e");
      rethrow;
    }
  }

  Future<User?> logIn(
      {String? email,
      String? password,
      required ProviderType provider}) async {
    try {
      UserCredential? userCredential;

      if (provider == ProviderType.google) {
        userCredential = await _firebaseAuth.logInWithGoogle();
      } else if (provider == ProviderType.password) {
        if (email != null && password != null) {
          userCredential = await _firebaseAuth.logInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          throw ArgumentError(
              "Email and password are required for password login.");
        }
      } else {
        throw UnsupportedError("Provider $provider is not supported.");
      }
      
      if(userCredential?.user != null) {
        if (userCredential?.user != null) {
          final token = await userCredential!.user?.getIdToken(); // Get Firebase ID token
          if (token !=null) {
            await prefs.setUserAuthToken(token);  //await prefs.writeSecure(key: 'authToken', value: token);
          }
          await prefs.setUserLoggedInTime(DateTime.now());
          await prefs.setUserIsLoggedin(true);
        }
        return userCredential!.user;
      } else {
        return null;
      }
    } catch (e) {
      _log.e("Login Error: $e");
      rethrow;
    }
  }
  
  Future<bool> isUserLoggedIn() async {                  // Check login status at startup
   // Check login status at startup
    final token = prefs.userAuthToken ;// await prefs.read('authToken');
    final bool isUserLoggedin = prefs.isUserLoggedin;
    final bool hasAuthUser = currentAuthUser != null;
    if (token == null || !isUserLoggedin || !hasAuthUser) {
      // No token, no login.
      _log.i('User is not logged in');
      return false;
    }

    try {
      // Attempt to re-authenticate.
      _log.i('trying to log in...');
      await _firebaseAuth.firebaseAuth.currentUser?.reload();
      _log.i('User reload is successfull');
      return true; // Successfully re-authenticated.
    } catch (e) {
      // Re-authentication failed.
      _log.i('User reload failed, $e');
      prefs.setUserIsLoggedin(false); // Reset the state of user loggedin
      prefs.setUserAuthToken(null); //await prefs.deleteSecure('authToken');
      return false;
    }
  }

  Future<bool> logOut()async {
    final token = prefs.userAuthToken;//await prefs.readSecure('authToken');
    await prefs.setUserLoggedOffTime(DateTime.now());
    await prefs.setUserIsLoggedin(false);
    await _firebaseAuth.logOut();
    return token != null && (prefs.isUserLoggedin) ; 
  }

  Future<void> resetPass(String email) async{
    try {
      if(email.isNotEmpty){
        await _firebaseAuth.sendPasswordResetEmail(email);
      }
    } on Exception catch (e) {
      _log.e('Error reseting pass: $e');
      rethrow;
    }
  }

  Future<void> updatePass({required String code,required String newPassword}) async{
    try {
    await _firebaseAuth.verifyResetCode(code);
    await _firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    }
    catch (e) {
            _log.e('Error creating user by admin: $e');
            rethrow;
    }  
  }
  
}


