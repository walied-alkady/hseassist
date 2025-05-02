class UserData {
  final int points;
  final Map<String, int> quizeLevelsAvailable;

  UserData({
    this.points = 0,
    required this.quizeLevelsAvailable,
  });
}