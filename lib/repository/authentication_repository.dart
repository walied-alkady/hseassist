import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Exceptions/authentication_exception.dart';
import 'logging_reprository.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kDebugMode, kIsWeb;


/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository() ;
  final _log = LoggerReprository('AuthenticationRepository');
  final String webClientId = dotenv.env['googleSignInwebClientId']!;
  late final googleSignIn = GoogleSignIn(clientId: kIsWeb ? webClientId : null);
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  /// Whether or not the current environment is web
  /// Should only be overridden for testing purposes. Otherwise,
  /// defaults to [kIsWeb]
  @visibleForTesting
  bool isWeb = kIsWeb;
  
  Future<void> initEmulator() async {
    _log.i('Initializing Auth emulator...');
    const emulatorPortAuth = 9099;
    final emulatorHost =(!kIsWeb && defaultTargetPlatform == TargetPlatform.android)? '10.0.2.2': 'localhost';
    if (defaultTargetPlatform != TargetPlatform.android && kDebugMode) {
      await firebaseAuth.useAuthEmulator(emulatorHost, emulatorPortAuth);
    }
    _log.i('Done...');
  }
  
  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  Future<UserCredential?> signUp({
    required String email, 
    required String password
    }) async {
    try {
      final cred =  await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _log.i('logged in!');
      return cred;
    } on FirebaseAuthException catch (e) {
      throw RegisterFirebaseFailure.fromCode(e.code);
    } catch (_) {
      throw RegisterFirebaseFailure('error in create user with email pass');
    }
  }
  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<UserCredential?> logInWithGoogle() async {
    try {
      _log.i('logging in with google...');
      late final AuthCredential credential;
      if (isWeb) {
        _log.i('using web log in...');
        final googleProvider = GoogleAuthProvider();
        final userCredential = await firebaseAuth.signInWithPopup(
          googleProvider,
        );
        credential = userCredential.credential!;
      } else {
        final googleUser = await googleSignIn.signIn();
        final googleAuth = await googleUser!.authentication;
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }
      _log.i('logging in with google!');
      return await firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw LoginGoogleFirebaseFailure.fromCode(e.code);
    } catch (e) {
      throw LoginGoogleFirebaseFailure('$e');
    }
  }
  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<UserCredential> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _log.i('logging in with email pass credencials...');
      final usrCred =  await  firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    _log.i('finding credential user...');
    return usrCred;
    } on FirebaseAuthException catch (e) {
      throw LoginEmailPassFirebaseFailure.fromCode(e.code);
    } catch (e) {
      throw LoginEmailPassFirebaseFailure('$e');
    }
  }
  ///
  Future<void> verify() async{
    final user = firebaseAuth.currentUser;
    final actionCodeSettings = ActionCodeSettings(
      url: "http://www.greasework.com/verify?email=${user?.email}",
      iOSBundleId: "com.walidKSoft.greasework",
      androidPackageName: "com.walidKSoft.greasework",
    );
    await user?.sendEmailVerification(actionCodeSettings);
  }
  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]).then((value){
        _log.i('signed out');
    });
    } catch (e) {
      throw LogoutFailure('$e');
    }
  }
  // Reset pass
  Future<void> sendPasswordResetEmail(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: email,
      // Optional: Customize the action code settings for more control
      //TODO: modify auth action code
      actionCodeSettings: ActionCodeSettings(
        url: 'https:/greasework.firebaseapp.com/resetPassword', // Your password reset page
        //handleCodeInApp: true, // Handle the code directly in your app
        //androidPackageName: 'com.walidKSoft.greasework', // For Android
        //iOSBundleId: 'com.yourcompany.yourapp', // For iOS
        //dynamicLinkDomain: 'your-app.page.link', // For dynamic links
      ),
    );
    // Optionally show a success message to the user
    _log.i('Password reset email sent!');
  } on FirebaseAuthException catch (e) {
      throw ResetPassFirebaseFailure.fromCode(e.code);
    } catch (e) {
      throw ResetPassFirebaseFailure('$e');
    }
}
// check action code 
  Future<void> verifyResetCode(String code) async {
    try {
      await FirebaseAuth.instance.verifyPasswordResetCode(code);
      // Code is valid, allow the user to enter a new password
      _log.e('Code verified, you can now reset the password.');
    } on FirebaseAuthException catch (e) {
      throw ResetPassFirebaseFailure.fromCode(e.code);
    } catch (e) {
      throw ResetPassFirebaseFailure('$e');
    }
  }
  // Confirm pass
  Future<void> confirmPasswordReset({required String code,required String newPassword}) async {
    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      // Password reset successful!
      _log.i('Password reset successfully!');
    } on FirebaseAuthException catch (e) {
      throw ResetPassFirebaseFailure.fromCode(e.code);
    } catch (e) {
      throw ResetPassFirebaseFailure('$e');
    }
  }
  /// 
  /// delete user
  Future<void> deleteUserAccount() async {
  try {
    _log.i('deleting user account...');
    await FirebaseAuth.instance.currentUser!.delete();
    _log.i('user account is deleted!');
  } on FirebaseAuthException catch (e) {
    _log.e(e);
    if (e.code == "requires-recent-login") {
      await _reauthenticateAndDelete();
    } else {
      throw DeleteAccountFirebaseFailure.fromCode('$e');
    }
  } catch (e) {
      throw DeleteAccountFirebaseFailure('$e');
    }
}

  Future<void> _reauthenticateAndDelete() async {
  try {
    _log.i('reauthenticating user!');
    final providerData = firebaseAuth.currentUser?.providerData.first;
    if (AppleAuthProvider().providerId == providerData!.providerId) {
      await firebaseAuth.currentUser!
          .reauthenticateWithProvider(AppleAuthProvider());
    } else if (GoogleAuthProvider().providerId == providerData.providerId) {
      await firebaseAuth.currentUser!
          .reauthenticateWithProvider(GoogleAuthProvider());
    }
    await firebaseAuth.currentUser?.delete();
    _log.i('Done...');
  } on FirebaseAuthException catch (e) {
    throw DeleteAccountFirebaseFailure.fromCode('$e');
  } catch (e) {
    throw DeleteAccountFirebaseFailure('$e');
  }
}

}

