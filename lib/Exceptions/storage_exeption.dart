import 'package:get_it/get_it.dart';

import '../repository/logging_reprository.dart';

final log = GetIt.instance<LoggerReprository>()..name = 'StorageExceptions';

class UploadImageFailure implements Exception{

  UploadImageFailure([
    this.message = 'An unknown exception occurred.'
  ]){
    log.e(message);
  }
  final String message;
}