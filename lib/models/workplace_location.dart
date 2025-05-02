
import 'model_base.dart';

class WorkplaceLocation extends ModelBase{
    
  static const collectionString = 'WorkplaceLocations';

  static const empty = WorkplaceLocation(id: '');

  ///region Getters
  @override
  bool get isEmpty => this == WorkplaceLocation.empty ;
  @override
  bool get isNotEmpty => this != WorkplaceLocation.empty;

  const WorkplaceLocation({
    required this.id,
    this.description='',
    this.managerId='',
  });
  final String id;
  final String description;
  final String managerId;

  @override
  List<Object?> get props => [
    id,
    description,
    managerId,
  ];
  @override
  Map<String, dynamic> toMap()=> {
          WorkplaceLocationFields.id.name: id,
          WorkplaceLocationFields.description.name: description,
          WorkplaceLocationFields.managerId.name: managerId,
    };

  @override
  factory WorkplaceLocation.fromMap(Map<dynamic, dynamic> data) => WorkplaceLocation(
      id: data[WorkplaceLocationFields.id.name] ?? '',
      description: data[WorkplaceLocationFields.description.name] ?? '',
      managerId: data[WorkplaceLocationFields.managerId.name] ?? '',
      );
}

enum WorkplaceLocationFields {
  id,
  description,
  managerId,
}


extension WorkplaceLocationFieldsExtension on WorkplaceLocationFields {
    String get name {
    // Map-based lookup
    return {
      WorkplaceLocationFields.id: 'id',
      WorkplaceLocationFields.description: 'description',
      WorkplaceLocationFields.managerId: 'managerId',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}