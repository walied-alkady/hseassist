
import 'model_base.dart';

class QuizeGameQuize extends ModelBase{
    
  static const collectionString = 'QuizeGameQuize';

  static const empty = QuizeGameQuize(id: '', question: '', options: [], correctIndex: 0);

  ///region Getters
  @override
  bool get isEmpty => this == QuizeGameQuize.empty ;
  @override
  bool get isNotEmpty => this != QuizeGameQuize.empty;

  const QuizeGameQuize({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.hint='',
    this.questionType='text',
    this.level=0,
  });
  final String id;
  final String question;
  final List<String> options;
  // zero based index of correct value
  final int correctIndex;
  final String hint;
  // string or image
  final String questionType; 
  // [easy , beginner ,  medium , hard , expert ]
  final int level; 


    @override
  List<Object?> get props => [
    id,
    question,
    options,
    correctIndex,
    hint,
    questionType,
    level,
  ];
  @override
  Map<String, dynamic> toMap()=> {
          QuizeGameQuizeFields.id.name: id,
          QuizeGameQuizeFields.question.name: question,
          QuizeGameQuizeFields.options.name: options,
          QuizeGameQuizeFields.correctIndex.name: correctIndex,
          QuizeGameQuizeFields.hint.name: hint,
          QuizeGameQuizeFields.questionType.name: questionType,
          QuizeGameQuizeFields.level.name: level,
    };

  @override
  factory QuizeGameQuize.fromMap(Map<dynamic, dynamic> data) => QuizeGameQuize(
      id: data[QuizeGameQuizeFields.id.name] ?? '',
      question: data[QuizeGameQuizeFields.question.name] ?? '',
      options: data[QuizeGameQuizeFields.options.name] ?? [],
      correctIndex: data[QuizeGameQuizeFields.correctIndex.name] ?? 0,
      hint: data[QuizeGameQuizeFields.hint.name] ?? '',
      questionType: data[QuizeGameQuizeFields.questionType.name] ?? '',
      level: data[QuizeGameQuizeFields.level.name] ?? '',
      );
}

enum QuizeGameQuizeFields {
  id,
  question,
    options,
    correctIndex,
    hint,
    questionType,
    level,  
}


extension QuizeGameQuizeFieldsExtension on QuizeGameQuizeFields {
    String get name {
    // Map-based lookup
    return {
      QuizeGameQuizeFields.id: 'id',
      QuizeGameQuizeFields.question: 'question',
      QuizeGameQuizeFields.options: 'options',
      QuizeGameQuizeFields.correctIndex: 'correctIndex',
      QuizeGameQuizeFields.hint: 'hint',
      QuizeGameQuizeFields.questionType: 'questionType',
      QuizeGameQuizeFields.level: 'level',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}