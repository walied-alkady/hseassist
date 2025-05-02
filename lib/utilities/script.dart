import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;
import 'dart:async';

// dart run lib\utilities\script.dart

// Future<Map<String, dynamic>> loadJsonFromAssets(String path) async 
//   { 
//     String jsonString = await rootBundle.loadString(path); 
//     return jsonDecode(jsonString);
//   }

Future<void> generateFile () async { 

    final current = Directory.current;
    final source = Directory.fromUri(Uri.parse('assets/translations'));
    final output = Directory.fromUri(Uri.parse('lib/utilities'));
    final sourcePath = Directory(path.join(current.path, source.path));
    stderr.writeln(sourcePath.path);  
    if (!await sourcePath.exists()) {
      stderr.writeln('Source path does not exist');
      return;
    }
    final outputPath = Directory(path.join(current.path, output.path, 'translations.dart'));
    final file = File(Directory(path.join(current.path, source.path, 'langs.csv')).path);
    final input = await file.readAsString();
    List<List<String>> rowsAsListOfValues = const CsvToListConverter().convert(input);

    //final jsonString = await loadJsonFromAssets('lib/translations.json'); 
    final List<Map<String, dynamic>> jsonMap = convertCsvToKeyValue(rowsAsListOfValues);
    // int i  = 0;
    // jsonMap[1].forEach((key, value) 
    //     { 
    //       if(i>5) {
    //         return;
    //       }
    //       stderr.writeln("  '$key' : '$value',"); 
    //       i++;
    //     }); 
    // return;
    final classBuilder = StringBuffer(); 
    classBuilder.writeln('import \'dart:ui\';'); 
    classBuilder.writeln('import \'package:easy_localization/easy_localization.dart\' show AssetLoader;'); 
    classBuilder.writeln('class CodegenLoader extends AssetLoader {'); 
    classBuilder.writeln('const CodegenLoader();'); 
    classBuilder.writeln('@override'); 
    classBuilder.writeln('Future<Map<String, dynamic>> load(String fullPath, Locale locale) {'); 
    classBuilder.writeln('  return Future.value(mapLocales[locale.toString()]);'); 
    classBuilder.writeln('}'); 
    int langCounter = 1;
    while (langCounter < rowsAsListOfValues[0].length){
      classBuilder.writeln("static const Map<String, dynamic>  ${rowsAsListOfValues[0][langCounter]} = {"); 
        jsonMap[langCounter-1].forEach((key, value) 
        { 
          if(value.contains('\'')){
            value = value.replaceAll('\'', '\\\'');
          }
          classBuilder.writeln("  '$key' : '$value',"); 
        }); 
      classBuilder.writeln('};'); 
      langCounter++;
    }
    classBuilder.writeln('static const Map<String, Map<String, dynamic>> mapLocales = {'); 
    for (var value in rowsAsListOfValues[0]) { 
          if(value == 'str'){
            continue;
          }
          classBuilder.writeln(' "$value" : $value ,');
          //classBuilder.writeln(' "${value.substring(0,2)}" : ${value.substring(0,2)} ,');
      } 
    classBuilder.writeln(' };');
    classBuilder.writeln('}'); 
    classBuilder.writeln();
    classBuilder.writeln('abstract class Strings {');
    jsonMap[1].forEach((key, value) 
        { 
          String labelName = key;
          String varName = key;
          if(varName.contains('.')){
            varName = varName.replaceAll('.', '_');
            List<String> parts = varName.split('_');
            for (int i = 1; i < parts.length; i++) { // Capitalize from the second part onwards
              parts[i] = parts[i][0].toUpperCase() + parts[i].substring(1);
            }
            varName = parts.join('');
          }
          
          classBuilder.writeln("  static const $varName = '$labelName';"); 
        }); 
    classBuilder.writeln('}');
    final generatedCode = classBuilder.toString(); 
    //stderr.writeln(generatedCode); 
    final outputFile = File(outputPath.path); 
    outputFile.writeAsStringSync(generatedCode);
}
List<String> getLangsList(List<List<dynamic>> data) { 
  List<String> result = []; 
  List<dynamic> headers = data[0]; 
  for (var i = 1; i < headers.length; i++) { 
    result.add(headers[i]);  
    } 
  return result;
}

List<Map<String, dynamic>> convertCsvToKeyValue(List<List<String>> data) { 
  List<Map<String, dynamic>> result = []; 
  List<String> headers = data[0];   
  int langCounter = 1;
  while (langCounter < headers.length){
  Map<String, dynamic> lang = {};   
    for (var i = 1; i < data.length; i++) { 
      for (var j = 0; j < headers.length; j++) { 
        lang[data[i][0]] = data[i][langCounter];
      } 
    }
    result.add(lang);
    langCounter++;
  }
  return result;
}

Future<List<FileSystemEntity>> dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file),
      onDone: () => completer.complete(files));
  return completer.future;
}

void main(){
  generateFile();
}

