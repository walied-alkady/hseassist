
import '../enums/query_operator.dart';

class FirestoreQuery {
  final String field;
  final dynamic value;
  final QueryComparisonOperator operator; 

  FirestoreQuery({
    required this.field,
    required this.value,
    this.operator = QueryComparisonOperator.eq,
  });

  // You can add more methods here later if you need to build complex queries

  //optional
  Map<String, dynamic> toMap() {
    return {
      'field': field,
      'value': value,
      'operator': operator.name,
    };
  }
}

class FirestoreComplexQuery {
  final String? mainOperator;
  final List<FirestoreQuery>? queries;

  FirestoreComplexQuery({this.mainOperator, this.queries});

  //optional
  Map<String, dynamic> toMap() {
    return {
      'mainOperator': mainOperator,
      'queries': queries?.map((e) => e.toMap()).toList(),
    };
  }
}