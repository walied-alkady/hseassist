import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:hseassist/Exceptions/storage_exeption.dart' show UploadImageFailure;
import 'dart:io' as io; // Import dart:io as io

//import '../exceptions/storage_exeption.dart'; // Assuming this is your custom exception file
import '../repository/logging_reprository.dart';
import '../repository/storage_repository.dart';


// class StorageService{
//   StorageService({this.withEmulator = false}) ;  
//   late final StorageRepository _firebaseStorage = withEmulator?(StorageRepository()..initEmulator()):StorageRepository();

//   final _log = LoggerReprository('StorageService');
//   final bool withEmulator;
//   Future<UploadTaskResult> uploadImage({required String id,required Uint8List  imageFile}) async {
//     const userProfilePhoto = 'profilePhoto';
//     //final tempName = DateTime.now().millisecondsSinceEpoch;
//     try {
//       final uploadTask = await _firebaseStorage.uploadFileWeb(
//             bytes: imageFile, path: userProfilePhoto, name: id);
//       if(uploadTask==null){
//         throw UploadImageFailure('Error uploading image');
//       }
//       // Listen for upload progress
//       uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
//         final progress =
//             100.0 * (snapshot.bytesTransferred / snapshot.totalBytes);
//         _log.i("Upload is $progress% complete.");
//         // Update your UI with the progress here
//       });

//       // Handle successful upload using `then`
//       final downloadURL = await uploadTask.then((snapshot) async {
//         // Get download URL directly from the snapshot
//         return await snapshot.ref.getDownloadURL();
//       });
//       return UploadTaskResult(success: true, downloadURL: downloadURL, errorMessage: null);
//     } catch (e) {
//       _log.e('Error uploading image: $e');
//       rethrow;
//     }
// }
  
// }

class StorageService {
  StorageService({this.withEmulator = false});

  late final StorageRepository _firebaseStorage =
      withEmulator ? (StorageRepository()..initEmulator()) : StorageRepository();

  final _log = LoggerReprository('StorageService');
  final bool withEmulator;

  Future<UploadTaskResult> uploadImage({
    required String photoPath,
    required String photoName,
    required Uint8List imageFile, 
    Function(double)? onProgress, 
  }) async {
    try {
      UploadTask uploadTask;  // Declare uploadTask outside the if

      if (kIsWeb) {
        uploadTask = await _firebaseStorage.uploadData( 
            path: photoPath,
            name: photoName,
            data: imageFile,
            onProgress: onProgress,
          );
      } else {
        final tempFile = io.File.fromRawPath(imageFile);  // Create a temporary io.File
        uploadTask = await _firebaseStorage.uploadFile(
          file: tempFile,  // Pass the temporary file
          path: photoPath,
          name: photoName,
          onProgress: onProgress,
        );
      }
      final downloadURL = await uploadTask.then((snapshot) async {
        return await snapshot.ref.getDownloadURL();
      });
      return UploadTaskResult(
        success: true,
        downloadURL: downloadURL,
        errorMessage: null,
      );
    
    } on FirebaseException catch (e) {
      _log.e('Firebase Storage Error uploading image: $e');
      // Consider using more specific exceptions based on e.code
      throw UploadImageFailure('Error uploading image: ${e.message}');
    } catch (e) {
      _log.e('Error uploading image: $e');
      throw UploadImageFailure('Error uploading image: $e');
    }
  }
}

class UploadTaskResult {
  final bool success;
  int taskProgress = 0;
  final String? downloadURL;
  final String? errorMessage;

  UploadTaskResult(
      {required this.success, this.downloadURL, this.errorMessage});
}

