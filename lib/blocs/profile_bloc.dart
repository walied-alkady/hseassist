import 'dart:io';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/service/storage_service.dart';
import 'package:image_picker/image_picker.dart';

import '../Exceptions/database_exception.dart';
import '../enums/form_status.dart';
import '../models/models.dart';
import '../repository/logging_reprository.dart';
import '../service/authentication_service.dart';
import '../service/database_service.dart';
import 'manager.dart';


class ProfileFormUpdate extends Equatable{

  const ProfileFormUpdate({
    this.autovalidateMode = AutovalidateMode.disabled, 
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.displayName = '',
    this.displayNameLocal = '',
    this.phoneNo = '',
    this.photoURL = '',
    this.isEmailVerified = false,
    this.role = '',
    this.notes = '',
    this.imageFile, 

    this.errorMessage,
    this.status = FormStatus.initial,
    this.userGroups = const <String>[],
    this.uploadProgress
  });

  final AutovalidateMode autovalidateMode;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String displayNameLocal;
  final String phoneNo;
  final String photoURL;
  final bool isEmailVerified;
  final String role;
  final String notes;
  final File? imageFile;
  final List<String> userGroups ;

  final FormStatus status;
  final String? errorMessage;
  final double? uploadProgress;
  @override
  List<Object?> get props => [
        email,
        firstName,
        lastName,
        displayName,
        displayNameLocal,
        phoneNo,
        photoURL,
        isEmailVerified,
        imageFile, 
        notes,
        role,

        userGroups,
        status,
        errorMessage,
        uploadProgress
      ];

  ProfileFormUpdate copyWith({
    AutovalidateMode? autovalidateMode,
    String? email,
    String? firstName,
    String? lastName,
    String? displayName,
    String? displayNameLocal,
    String? photoURL,
    String? phoneNo,
    bool? isEmailVerified,
    String? role,
    String? notes,
    File? imageFile,

    FormStatus? status,
    bool? isValid,
    String? errorMessage,
    List<String>? userGroups,
    double? uploadProgress
  }) {
    return ProfileFormUpdate(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      displayNameLocal: displayNameLocal ?? this.displayNameLocal,
      phoneNo: phoneNo ?? this.phoneNo,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      imageFile: imageFile ?? this.imageFile,
      
      notes: notes ?? this.notes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userGroups: userGroups ?? this.userGroups,
      uploadProgress: uploadProgress ?? this.uploadProgress
      
    );
  }
}

class ProfileCubit extends Cubit<ProfileFormUpdate> with Manager<ProfileCubit>{

  ProfileCubit({
    required AuthenticationService authService,
    required DatabaseService db,
    required LoggerReprository log,
    required StorageService storage
  }) : super(const ProfileFormUpdate()); 

  final _log = LoggerReprository('ProfileCubit');
  
  void initForm(){
    emit(state.copyWith(
      email: db.currentUser?.email,
      firstName: db.currentUser?.firstName,
      lastName: db.currentUser?.lastName,
      displayName: db.currentUser?.displayName,
      displayNameLocal: db.currentUser?.displayNameLocal,
      phoneNo: db.currentUser?.phoneNumber,
      photoURL: db.currentUser?.photoURL,
      role: db.currentUser?.currentWorkplaceRole,
      notes: db.currentUser?.notes,
    ));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  void updateEmail(String? email) {
    emit(state.copyWith(email: email));
  }
  
  void updateFirstName(String? firstName) {
    emit(state.copyWith(firstName: firstName));
  }

  void updateLastName(String? lastName) {
    emit(state.copyWith(lastName: lastName));
  }
    
  void updateDisplayName(String? displayName) {
    emit(state.copyWith(displayName: displayName));
  }

  void updateDisplayNameLocal(String? displayNameLocal) {
    emit(state.copyWith(displayNameLocal: displayNameLocal));
  }

  void updatePhoneNo(String? phoneNo) {
    emit(state.copyWith(phoneNo: phoneNo));
  }

  Future<void> updatePhotoURL(String? photoURL) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    File?  imageFile;
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      Uint8List bytes = await pickedFile.readAsBytes(); 
  
      final url = await storage.uploadImage(
        photoPath: "profilePhotos/",
        photoName: prefs.currentUserId,
        imageFile: bytes,
        onProgress: (progress){
                emit(state.copyWith(uploadProgress: progress));
              }
        )
        .then((value) => value.downloadURL,);
      if (url == null) return;
      emit(
          state.copyWith(
            photoURL: url,
            imageFile: imageFile,
          ),
        );
    }
  }

  void updateNotes(String? notes) {
    emit(state.copyWith(notes: notes));
  }

  void reset() {
    emit(const ProfileFormUpdate());
  }
  
  Future<void> saveProfile() async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      if (db.currentUser!.isNotEmpty){
      final Map<String,dynamic> newUs = {
            AuthUserFields.email.name: state.email,
            AuthUserFields.firstName.name : state.firstName,
            AuthUserFields.lastName.name: state.lastName,
            AuthUserFields.displayName.name: state.displayName,
            AuthUserFields.displayNameLocal.name: state.displayNameLocal,
            AuthUserFields.phoneNumber.name: state.phoneNo,
            AuthUserFields.photoURL.name: state.photoURL,
            AuthUserFields.notes.name: state.notes,
      };
      await db.updateOne<AuthUser>(prefs.currentUserId,newUs);
      emit(state.copyWith(status: FormStatus.success));
      }else{
        emit(state.copyWith(status: FormStatus.failure));
      }
    } on DatabaseFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormStatus.failure,
        ),
      );
    }  
    on Exception catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          status: FormStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormStatus.failure));
    }
  }

}