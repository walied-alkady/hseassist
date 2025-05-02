
import 'model_base.dart';

class QuizeGameCategory extends ModelBase{
    
  static const collectionString = 'QuizeGameCategory';

  static const empty = QuizeGameCategory(id: '', quizeName: '', description: '', difficulty: '', quizes: []);

  ///region Getters
  @override
  bool get isEmpty => this == QuizeGameCategory.empty ;
  @override
  bool get isNotEmpty => this != QuizeGameCategory.empty;

  const QuizeGameCategory({
    required this.id,
    required  this.quizeName,
    required  this.description,
    this.iconImage,
    required  this.difficulty,
    required this.quizes,

  });
  final String id;
  final String quizeName;
  final String description;
  final String? iconImage;
  final String difficulty;
  final List<String> quizes;
    @override
  List<Object?> get props => [
    id,
    quizeName,
    description,
    iconImage,
    difficulty,
    quizes,
  ];
  @override
  Map<String, dynamic> toMap()=> {
          QuizeGameCategoryFields.id.name: id,
          QuizeGameCategoryFields.quizeName.name: quizeName,
          QuizeGameCategoryFields.description.name: description,
          QuizeGameCategoryFields.iconImage.name: iconImage,
          QuizeGameCategoryFields.difficulty.name: difficulty,
          QuizeGameCategoryFields.quizes.name: quizes,
    };

  @override
  factory QuizeGameCategory.fromMap(Map<dynamic, dynamic> data) => QuizeGameCategory(
      id: data[QuizeGameCategoryFields.id.name] ?? '',
      quizeName: data[QuizeGameCategoryFields.quizeName.name] ?? '',
      description: data[QuizeGameCategoryFields.description.name] ?? '',
      iconImage: data[QuizeGameCategoryFields.iconImage.name] ?? '',
      difficulty: data[QuizeGameCategoryFields.difficulty.name] ?? '',
      quizes: data[QuizeGameCategoryFields.quizes.name] ?? [],
      );
}

enum QuizeGameCategoryFields {
  id,
  quizeName,
  description,
  iconImage,
  difficulty,
  quizes,
}


extension QuizeGameCategoryFieldsExtension on QuizeGameCategoryFields {
    String get name {
    // Map-based lookup
    return {
      QuizeGameCategoryFields.id: 'id',
      QuizeGameCategoryFields.quizeName: 'quizeName',
      QuizeGameCategoryFields.description: 'description',
      QuizeGameCategoryFields.iconImage: 'iconImage',
      QuizeGameCategoryFields.difficulty: 'difficulty',
      QuizeGameCategoryFields.quizes: 'quizes',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}