import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io' as io;

import 'logging_reprository.dart'; 

// class StorageRepository{
//   final _storage = FirebaseStorage.instance;
//   final _log = LoggerReprository('StorageRepository');

//   Future<void> initEmulator() async {
//     _log.i('Initializing storage emulator...');
//     const emulatorPortStoreage = 9199;
//     final emulatorHost =(!kIsWeb && defaultTargetPlatform == TargetPlatform.android)? '10.0.2.2': 'localhost';
//     if (defaultTargetPlatform != TargetPlatform.android && kDebugMode) {
//       _storage.useStorageEmulator(emulatorHost, emulatorPortStoreage);
//     }
//     _log.i('Done...');
//   }
//   /// The user selects a file, and the task is added to the list.
//   Future<UploadTask?> uploadFile({required File file, required String path, required String name, Function(double)? onProgress}) async {
//     late UploadTask uploadTask;
//     _log.i(name);
//     try{
//       _log.i('uploadFile: Starting upload for file: ${file.path}, path: $path, name: $name'); 
//       // Create a Reference to the file
//       Reference ref = _storage.ref('$path/$name');
//       //final metadata = SettableMetadata();

//       // final metadata = SettableMetadata(
//       //   contentType: 'image/${file.fileExtension}',
//       //   customMetadata: {'picked-file-path': file.path},
//       // );
//       if (kIsWeb) {
//         _log.i('uploading from web to the storage...');
//         final bytes = await file.readAsBytes();
//         uploadTask = ref.putData(bytes);
//         _trackUploadProgress(uploadTask, onProgress);
//       } else {
//         _log.i('uploading from mobile to the storage...');
//         uploadTask = ref.putFile(io.File(file.path));
//         _trackUploadProgress(uploadTask, onProgress);
//       }
//       _log.i('Done uploading...');
//       return Future.value(uploadTask);
//         }catch (e) {
//     _log.e('uploadFile: Error during upload: $e');
//     throw Exception('Failed to upload file: $e');
//   }

//   }
  
//   Future<UploadTask?> uploadFileWeb({required Uint8List bytes, required String path, required String name}) async {
//     late UploadTask uploadTask;
//     _log.i(name);
//     try{
//       _log.i('uploadFile: Starting upload for bytes: path: $path, name: $name'); 
//       // Create a Reference to the file
//       Reference ref = _storage.ref('$path/$name');
//       _log.i('uploading from web to the storage...');
//       uploadTask = ref.putData(bytes);
//       _log.i('Done uploading...');
//       return Future.value(uploadTask);
//         }catch (e) {
//     _log.e('uploadFile: Error during upload: $e');
//     throw Exception('Failed to upload file: $e');
//   }

//   }
//   /// A new string is uploaded to storage.
//   /// language : 'en' 
//   /// customMetadata: <String, String>{'example': 'putString'},
//   UploadTask uploadString({
//     required String txtData, 
//     required String path, 
//     required String name,
//     language = 'en',
//     Map<String, String>? customMetadata,
//     }) {
//     // Create a Reference to the file
//     Reference ref = _storage.ref('$path/$name.txt');

//     // Start upload of putString
//     return ref.putString(
//       txtData,
//       metadata: SettableMetadata(
//         contentLanguage: language,
//         customMetadata:  customMetadata //<String, String>{'example': 'putString'},
//       ),
//     );
//   }

//   Future<void> downloadBytes(String path) async {
//     final bytes = await _storage.ref(path).getData();
//     // Download...
//     //await saveAsBytes(bytes!, 'some-image.jpg');
//   }

//   ///If you already have download infrastructure based around URLs, 
//   ///or just want a URL to share, you can get the download URL for a file 
//   ///by calling the getDownloadURL() method on a Cloud Storage reference.
//   Future<void> downloadLink(String path) async {
//     final link = await _storage.ref(path).getDownloadURL();
//     await Clipboard.setData(
//       ClipboardData(
//         text: link,
//       ),
//     );

//     _log.i('Success!\n Copied download URL to Clipboard!');
//   }

//   Future<Uint8List?> downloadFile(String path,{int maxSize=1024 * 1024}) async {
//     //const oneMegabyte = 1024 * 1024;
//     Reference ref = _storage.ref(path);
//     final Uint8List? data = await ref.getData(maxSize);
//     return data;
//   }
  
//   Future<void> downloadTempFile(String path) async {
//     final ref = _storage.ref(path); 
//     final io.Directory systemTempDir = io.Directory.systemTemp;
//     final io.File tempFile = io.File('${systemTempDir.path}/temp-${ref.name}');
//     if (tempFile.existsSync()) await tempFile.delete();
//     await ref.writeToFile(tempFile);
//     _log.i(
//           'Success!\n Downloaded ${ref.name} \n from bucket: ${ref.bucket}\n '
//           'at path: ${ref.fullPath} \n'
//           'Wrote "${ref.fullPath}" to tmp-${ref.name}',
//         );
//   }

//   Future<void> delete(String path) async {
//     Reference ref = _storage.ref(path);
//     await ref.delete();
//     _log.i('Success!\n deleted ${ref.name} \n from bucket: ${ref.bucket}\n '
//             'at path: ${ref.fullPath} \n');
//   }

//   void _trackUploadProgress(UploadTask uploadTask, Function(double)? onProgress) {
//     uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
//       final progress = snapshot.bytesTransferred / snapshot.totalBytes;
//       if (onProgress != null) {
//         onProgress(progress); // Call the callback with the current progress
//       }
//     });
//   }
// }

class StorageRepository {
  final _storage = FirebaseStorage.instance;
  final _log = LoggerReprository('StorageRepository');

  Future<void> initEmulator() async {
    _log.i('Initializing storage emulator...');
    const emulatorPortStorage = 9199;
    final emulatorHost = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : 'localhost';
    if (defaultTargetPlatform != TargetPlatform.android && kDebugMode) {
      _storage.useStorageEmulator(emulatorHost, emulatorPortStorage);
    }
    _log.i('Done...');
  }

  Future<UploadTask> uploadData(
      {required Uint8List data,
      required String path,
      required String name,
      Function(double)? onProgress}) async {
    try {
      Reference ref = _storage.ref('$path/$name');
      final uploadTask = ref.putData(data);

      _trackUploadProgress(uploadTask, onProgress);
      return uploadTask;
    } catch (e) {
      _log.e('uploadFile: Error during upload: $e');
      rethrow; // Rethrow the original exception
    }
  }

  Future<UploadTask> uploadFile(
      {required File file,
      required String path,
      required String name,
      Function(double)? onProgress}) async {
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      return uploadData(
          data: bytes, path: path, name: name, onProgress: onProgress);
    } else {
      final uploadTask = _storage.ref('$path/$name').putFile(io.File(file.path));
      _trackUploadProgress(uploadTask, onProgress); // Track progress for mobile
      return uploadTask;
    }
  }

  UploadTask uploadString(
      {required String txtData,
      required String path,
      required String name,
      String language = 'en',
      Map<String, String>? customMetadata}) {
    Reference ref = _storage.ref('$path/$name.txt');

    return ref.putString(txtData,
        metadata: SettableMetadata(
            contentLanguage: language, customMetadata: customMetadata));
  }

  Future<Uint8List?> downloadFile(String path, {int maxSize = 1024 * 1024}) async {
    Reference ref = _storage.ref(path);
    return ref.getData(maxSize);
  }

  Future<String> getDownloadURL(String path) async {
    return _storage.ref(path).getDownloadURL();
  }

  Future<void> delete(String path) async {
    Reference ref = _storage.ref(path);
    try {
      await ref.delete();
      _log.i(
          'Deleted ${ref.name} from bucket: ${ref.bucket} at path: ${ref.fullPath}');
    } catch (e) {
      _log.e('Error deleting file: $e');
      rethrow;
    }
  }

  void _trackUploadProgress(UploadTask uploadTask, Function(double)? onProgress) {
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = 0.0;
        if(snapshot.totalBytes > 0) {
          progress = (snapshot.bytesTransferred / snapshot.totalBytes);
        }
        onProgress?.call(progress);
        _log.i("Upload progress: $progress"); // Log the progress
      }, onError: (Object e) {
        _log.e(e);
        if (e is FirebaseException) {
          _log.e(e.message);
        }
      });
  }
}