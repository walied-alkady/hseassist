import 'model_base.dart';

class MiniSession extends ModelBase{
    
  static const collectionString = 'MiniSessions';

  static const empty = MiniSession(id: '');

  ///region Getters
  @override
  bool get isEmpty => this == MiniSession.empty ;
  @override
  bool get isNotEmpty => this != MiniSession.empty;


  const MiniSession({
    required this.id,
    this.description='',
    this.targetType ='',
    this.sessionUrlAndStrings= const [],
  });
  final String id;
  final String description;
  final String targetType;
  final List<Map<String,String>> sessionUrlAndStrings;

    @override
  List<Object?> get props => [
    id,
    description,
    targetType,
    sessionUrlAndStrings,
  ];
  @override
  Map<String, dynamic> toMap()=> {
      MiniSessionFields.id.name: id,
      MiniSessionFields.description.name: description,
      MiniSessionFields.targetType.name: targetType,
      MiniSessionFields.sessionUrlAndStrings.name: sessionUrlAndStrings,
  };

  @override
  factory MiniSession.fromMap(Map<dynamic, dynamic> data) => MiniSession(
      id: data[MiniSessionFields.id.name],
      description: data[MiniSessionFields.description.name] ?? '',
      targetType: data[MiniSessionFields.targetType.name] ?? '',
      sessionUrlAndStrings: data[MiniSessionFields.sessionUrlAndStrings.name] ?? [],
      );
}

enum MiniSessionFields {
    id,
    description,
    targetType,
    sessionUrlAndStrings,
}

extension MiniSessionFieldsExtension on MiniSessionFields {
  String get name {
    return {
      MiniSessionFields.id: 'id',
      MiniSessionFields.description: 'description',
      MiniSessionFields.targetType: 'targetType',
      MiniSessionFields.sessionUrlAndStrings: 'sessionUrlAndStrings',
    }[this]!; 
  }
}