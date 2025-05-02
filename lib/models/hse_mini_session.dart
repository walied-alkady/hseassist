
import 'model_base.dart';

class HseMiniSession extends ModelBase{
    
  static const collectionString = 'MiniSessions';

  static const empty = HseMiniSession();

  ///region Getters
  @override
  bool get isEmpty => this == HseMiniSession.empty ;
  @override
  bool get isNotEmpty => this != HseMiniSession.empty;
  ///endregion


  const HseMiniSession(
    {
      this.id='',
      this.title='',
      this.descriptionPage1='',
      this.descriptionPage1Photo='',
      this.descriptionPage2='',
      this.descriptionPage2Photo='',
      this.descriptionPage3='',
      this.descriptionPage3Photo='',
  });
  final String id;
  final String title;
  final String descriptionPage1;
  final String descriptionPage1Photo;
  final String descriptionPage2;
    final String descriptionPage2Photo;
  final String descriptionPage3;
    final String descriptionPage3Photo;

  ///endregion

  @override
  List<Object?> get props => [
    id,
    title,
    descriptionPage1,
    descriptionPage1Photo,
    descriptionPage2,
    descriptionPage2Photo,
    descriptionPage3,
    descriptionPage3Photo,
  ];
  @override
  Map<String, dynamic> toMap()=> {
      HseMiniSessionFields.id.name:id,
      HseMiniSessionFields.title.name:title,
      HseMiniSessionFields.descriptionPage1.name:descriptionPage1,
      HseMiniSessionFields.descriptionPage1Photo.name:descriptionPage1Photo,
      HseMiniSessionFields.descriptionPage2.name:descriptionPage2,
      HseMiniSessionFields.descriptionPage2Photo.name:descriptionPage2Photo,
      HseMiniSessionFields.descriptionPage3.name:descriptionPage3,
      HseMiniSessionFields.descriptionPage3Photo.name:descriptionPage3Photo,
    };

  @override
  factory HseMiniSession.fromMap(Map<dynamic, dynamic> data) => HseMiniSession(
      id: data[HseMiniSessionFields.id.name]??'',
      title: data[HseMiniSessionFields.title.name]??'',
      descriptionPage1: data[HseMiniSessionFields.descriptionPage1.name]??'',
      descriptionPage1Photo: data[HseMiniSessionFields.descriptionPage1Photo.name]??'',
      descriptionPage2: data[HseMiniSessionFields.descriptionPage2.name]??'',
      descriptionPage2Photo: data[HseMiniSessionFields.descriptionPage2Photo.name]??'',
      descriptionPage3: data[HseMiniSessionFields.descriptionPage2.name]??'',
      descriptionPage3Photo: data[HseMiniSessionFields.descriptionPage2Photo.name]??'',
      );    
}

enum HseMiniSessionFields {
  id,
  title,
  descriptionPage1,
  descriptionPage1Photo,
  descriptionPage2,
  descriptionPage2Photo,
  descriptionPage3,
  descriptionPage3Photo,
}

extension HseMiniSessionExtension on HseMiniSessionFields {
  String get name {
    // Map-based lookup
    return {
      HseMiniSessionFields.id: 'id',
      HseMiniSessionFields.title: 'title',
      HseMiniSessionFields.descriptionPage1: 'descriptionPage1',
      HseMiniSessionFields.descriptionPage1Photo: 'descriptionPage1Photo',
      HseMiniSessionFields.descriptionPage2: 'descriptionPage2',
      HseMiniSessionFields.descriptionPage2Photo: 'descriptionPage2Photo',
      HseMiniSessionFields.descriptionPage3: 'descriptionPage3',
      HseMiniSessionFields.descriptionPage3Photo: 'descriptionPage3Photo',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}