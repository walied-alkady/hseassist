
import 'package:hsequize/models/quize.dart';

class QuizCategory {
  final String name;
  final String description;
  //final String iconImage;
  final List<Quiz> quizzes;
  final bool isUnlocked;

  const QuizCategory({
    required this.name,
    required this.description,
    //required this.iconImage,
    required this.quizzes,
    this.isUnlocked = true,
  });
}
