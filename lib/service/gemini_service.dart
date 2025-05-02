import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';
import '../repository/gemini_repository.dart';
import '../repository/logging_reprository.dart';
import 'database_service.dart';
import 'preferences_service.dart';

class GeminiService {
  GeminiService(this._db, this._prefs);
  final _log = LoggerReprository('GeminiService');
  final DatabaseService _db;
  final List<Content> _content = [];
  final PreferencesService _prefs;
  final List<ChatMessage> cachChatMessages = [];
  final List<ChatMessage> cachChatMessageHistory = [];
  GeminiRepository? geminiRepo;
  
  Future<void> init() async{
    try {
      _log.i('Loading GeminiService...');
      _log.i('clearing chat history from cach...');
      cachChatMessageHistory.clear();
      _log.i('getting chat history from prefs');
      final locations = await _db.findAll<WorkplaceLocation>();
      Workplace? currentWorkplace;
      _log.i('getting current workplace...');
      final currentUser = _db.currentUser;
      if(currentUser !=null ) {
        final _currentWorkplace = currentUser.currentWorkplace;
        if(_currentWorkplace !=null) {
          currentWorkplace = await _db.findOne<Workplace>(_currentWorkplace);
        }
      }
      final res = locations.map((e) => e.description).toList();
      geminiRepo = GeminiRepository(workplace: currentWorkplace?.activityType??'',locations: res);
      final botMessages = await _db.findAll<ChatMessage>(
        query: ChatMessageFields.chatId.name,
        queryValue: 'ai_bot_${_prefs.currentUserId}',
      );
      cachChatMessageHistory.addAll(botMessages);
      _log.i('GeminiService loaded...');
    } on Exception catch (e) {
      _log.e('$e');
      rethrow;
    }

  }
  /// **Summery**
  /// 
  /// Generate string response for the input [contentText]
  /// 
  /// ***Returns*** 
  /// 
  /// String? 
  ///   chat response text
  /// 
  /// ***Throws*** 
  /// 
  /// none
  Future<GenerateContentResponse> getGenerateTextResponse(String contentText)async {
    if(geminiRepo ==null) throw Exception('gemini has not been initialized...');
    if(contentText.isEmpty)throw Exception('content message is empty...');

    // Future<Map<String, Object?>> addWorkplaceIncident(Map<String, Object?> args) async{
    //   final incident = HseIncident.fromMap(functionCall.args); // Assuming HseIncident.fromMap exists
    //   await db.createHseIncident(incident);
    //   return args;
    // }
    // final functions = {'addWorkplaceIncident': addWorkplaceIncident};
    // FunctionResponse dispatchFunctionCall(FunctionCall call) {
    //   log.i('calling ${call.name}...');
    //   final function = functions[call.name]!;
    //   final result = function(call.args);
    //   log.i('got results from ${call.name}...');
    //   return FunctionResponse(call.name,result);
    // }
    _content.add(Content.text(contentText));
    _log.i('getting chat response...');
    var response = await geminiRepo!.model.generateContent(_content);
    List<FunctionCall> functionCalls;
    while ((functionCalls = response.functionCalls.toList()).isNotEmpty) {
      _log.i('response has functions...');
      var responses = <FunctionResponse>[
        for (final functionCall in functionCalls)
          await _dispatchFunctionCall(functionCall)
      ];
      _content
        ..add(response.candidates.first.content)
        ..add(Content.functionResponses(responses));
      _log.i('adding function responses to content...');
      response = await geminiRepo!.model.generateContent(_content);
    }
    _log.i('got response...');
    return response;
  }

  Future<FunctionResponse> _dispatchFunctionCall(FunctionCall functionCall) async{
    switch (functionCall.name) {
        case 'addWorkplaceIncident':
          try {
            final incident = HseIncident.fromMap(functionCall.args); // Assuming HseIncident.fromMap exists
            await _db.create<HseIncident>(incident);
            // Send an error response back to Gemini
            return FunctionResponse(functionCall.name,incident.toMap());
          } catch (e) {
            _log.e('Error adding incident: $e');
            FunctionResponse(functionCall.name,{});
          }
        break;
        case 'addWorkplaceHazard':
          try {
            final hazard = HseHazard.fromMap(functionCall.args); // Assuming HseIncident.fromMap exists
            await _db.create<HseHazard>(hazard);
            // Send an error response back to Gemini
            return FunctionResponse(functionCall.name,hazard.toMap());
          } catch (e) {
            _log.e('Error adding incident: $e');
            FunctionResponse(functionCall.name,{});
          }
        break;
        // ... cases for other function calls ...
        default:
          throw UnimplementedError('Function not implemented: ${functionCall.name}');
      }
    return FunctionResponse(functionCall.name,{});  
  }
  
  Future<List<double>> getEmbeddings(String text) async {
    if (geminiRepo == null) {
      throw Exception('Gemini has not been initialized.');
    }
    if (text.isEmpty) {
      throw Exception('Input text for embedding is empty.');
    }

    try {
      _log.i('Generating embedding for text: $text');
      final embeddingResponse = await geminiRepo!.embeddingModel.embedContent(Content.text(text));
      _log.i('Embedding generated successfully.');
      return embeddingResponse.embedding.values;
    } catch (e) {
      _log.e('Error generating embedding: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    // await geminiRepo?.model.close(); // If your model has a close method.
   //_subscription?.cancel(); // If you have any subscriptions.
    geminiRepo = null; // Good practice to release references.
  }
}