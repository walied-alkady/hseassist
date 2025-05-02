
import 'package:hsequize/enums.dart';

import 'quize_level.dart';

class Quiz {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String hint;
  final QuizQuestionType questionType;
  final QuizLevel level;
  const Quiz({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.hint,
    required this.questionType,
    required this.level,
  });
}
