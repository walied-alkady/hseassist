import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Exceptions/database_exception.dart';
import 'logging_reprository.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kDebugMode, kIsWeb;

enum QueryConstraint{
  equalToKey('key'),
  equalToId('id'),
  equalToUserId('userId'),
  equalToUserEmail('email'),
  equalToUserGroup('group'),
  equalToOrganization('organizationId')
  ;
  
  const QueryConstraint(this.by);
  final String by;
  @override
  String toString() => by;
}

class DatabaseRepository {
  
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final firebaseFunctions = FirebaseFunctions.instance;
  final _log = LoggerReprository('DatabaseRepository');
  
  Future<void> initEmulator() async {
    _log.i('Initializing firestore & functions emulators...');
    const emulatorPortDb = 9000;
    const emulatorPortFunctions = 5001;
    final emulatorHost =(!kIsWeb && defaultTargetPlatform == TargetPlatform.android)? '10.0.2.2': 'localhost';
    if (defaultTargetPlatform != TargetPlatform.android && kDebugMode) {
      _database.useDatabaseEmulator(emulatorHost, emulatorPortDb);
      firebaseFunctions.useFunctionsEmulator(emulatorHost, emulatorPortFunctions);
    
    }
  _log.i('Done...');
  }
  /// **Summery**
  /// 
  /// Generate new id for database in the [collectionName] path
  /// 
  /// ***Returns*** 
  /// 
  /// String? 
  ///   last token  in a Firebase Database location (e.g. ‘fred’ in https://SampleChat.firebaseIO-demo.com/users/fred)
  /// 
  /// ***Throws*** 
  /// 
  /// DatabaseFailure
  String? generateId(String collectionName){
    try {
      return _database.ref(collectionName).push().key;
    } on Exception catch (e) {
        throw DatabaseFailure('$e');
    }
  }
  /// **Summery**
  /// 
  /// Updates selected [values] in the [collectionName] with item collection [id] known
  /// 
  /// ***Returns*** void 
  /// 
  /// ***Throws*** 
  /// 
  /// DatabaseFailure 
  /// 
  /// ***Example***:
  /// ```dart
  /// DatabaseRepository db_rep = DatabaseRepository()
  /// db_rep.update('users','userid',values: data);
  /// ```
  Future<void> updateValues(String collectionName,String id,{required Map<String, dynamic> values}) async {
      try {
        await _database.ref('$collectionName/$id')
            .update(values);
      } on Exception catch (e) {
          throw DatabaseFailure('$e');
      }
  }
  /// **Summery**
  /// 
  /// updateAll in [collectionName] path overwriting any data at this location and all child locations
  /// 
  /// ***Returns*** void 
  /// 
  /// ***Throws*** 
  /// 
  /// DatabaseFailure
  Future<void> update(String collectionName,String id, {required Map<String, dynamic> values}) async {
      try {
        await _database.ref('$collectionName/$id')
          .set(values);
      } on Exception catch (e) {
        throw DatabaseFailure('$e');
      }
  }
  /// **Summery**
  /// 
  /// Add [collectionName] path with [values]
  /// optionally [id] of the item can be specified
  /// 
  /// ***Returns*** String  
  /// 
  /// last token in a Firebase Database location
  /// 
  /// ***Throws*** 
  /// 
  /// DatabaseFailure
  Future<String?> add(String collectionName,Map<String, dynamic> values,{String? id}) async {
    // final newPostKey =
    //     _database.ref(collectionName).push().key;
      try {
        DatabaseReference  newRef;
        String? newId;
        if(id==null || id.isEmpty){
          newRef = _database.ref(collectionName).push();
          newId = newRef.key;
        }else{
          newRef = _database.ref('$collectionName/$id');
          newId = id;
        }

        if (newId != null) {
            values['id'] = newId;
        }
        await newRef.set(values);
        return newId;
      } on Exception catch (e) {
        throw DatabaseFailure('$e');
      }
  }  
  /// **Summery**
  /// 
  /// Removes the specified [collectionName] with [id]
  /// 
  /// ***Returns*** String  
  /// 
  /// last token in a Firebase Database location
  /// 
  /// ***Throws*** 
  /// 
  /// DatabaseFailure
  Future<void> remove(String collectionName,String id) async {
    try {
        await _database.ref('$collectionName/$id').remove();
      } on Exception catch (e) {
        throw DatabaseFailure('$e');
      }
  } 
  /// **Summery**
  /// 
  /// gets a database quaery based on [collectionName] with optional [QueryConstraint] (startAt ,equalToId,... )
  /// and [queryValue]
  /// 
  /// ***Returns*** Query  
  /// 
  /// last token in a Firebase Database location
  Query  getReference(String collectionName,{QueryConstraint? constrainet,String? queryValue}) {
      switch (constrainet) {
      case QueryConstraint.equalToId:
          return _database
                  .ref(collectionName)
                  .orderByChild(QueryConstraint.equalToId.by)
                  .equalTo(queryValue);
      case QueryConstraint.equalToUserId:
          return _database
                  .ref(collectionName)
                  .orderByChild(QueryConstraint.equalToUserId.by)
                  .equalTo(queryValue);
      case QueryConstraint.equalToUserEmail:
          return _database
                  .ref(collectionName)
                  .orderByChild(QueryConstraint.equalToUserEmail.by)
                  .equalTo(queryValue);
          default:
            return _database
                  .ref(collectionName)
                  .orderByChild(QueryConstraint.equalToId.by)
                  .equalTo(queryValue);
      }
  }
  /// **Summery**
  /// 
  /// gets a database Reference based on [collectionName] with optional [QueryConstraint] (startAt ,equalToId,... )
  /// and [queryValue]
  /// 
  /// ***Returns*** Map<String, dynamic>  
  /// 
  /// A map representing the data at the specified location. 
  /// The keys of the map are the names of the children, and the values are the data for those children.
  /// 
  /// ***Throws*** 
  /// 
  /// DatabaseFailure
  Future<Map<String, dynamic>> getDatabaseEvent(String collectionName,
      {QueryConstraint? constraint, String? queryValue}) async {
    try {
      final DatabaseEvent event = await _getDatabaseEventInternal(
          collectionName, constraint, queryValue);

      if (event.snapshot.value != null) {
        if (constraint == QueryConstraint.equalToKey &&
            event.snapshot.value is Map) {
          // If equalToKey and the value is a Map:
          final dataMap = Map<String, dynamic>.from(event.snapshot.value as Map);

          // Get the first (and presumably only) entry's value
          final childValues = dataMap.values.first;

          // Return the child values as a Map<String, dynamic>
          return Map<String, dynamic>.from(childValues);
        } else {
          // For other constraints or if the value is not a Map,
          // return the entire snapshot as a map
          return {
            for (var entry in (event.snapshot.value as Map).entries)
              entry.key.toString(): entry.value
          };
        }
      } else {
        // Return an empty map if there's no data
        return {};
      }
    } on Exception catch (e) {
      throw DatabaseFailure('$e');
    }
  }
  /// **Summery**
  /// 
  /// gets a database Reference based on [collectionName] with optional [QueryConstraint] (startAt ,equalToId,... )
  /// and [queryValue]
  /// 
  /// ***Returns*** DataSnapshot  
  /// 
  /// last token in a Firebase Database location
  Future<Map<String, dynamic>> getDatabaseItems(String collectionName,
    {QueryConstraint? constraint,String? queryValue}) async {
      try {
      final DataSnapshot snapshot = await _getDatabaseSnapshotInternal(
          collectionName, constraint, queryValue);

      if (snapshot.value != null) {
        if (constraint == QueryConstraint.equalToKey &&
            snapshot.value is Map) {
          // If equalToKey and the value is a Map:
          final dataMap = Map<String, dynamic>.from(snapshot.value as Map);

          // Get the first (and presumably only) entry's value
          final childValues = dataMap.values.first;

          // Return the child values as a Map<String, dynamic>
          return Map<String, dynamic>.from(childValues);
        } else {
          // For other constraints or if the value is not a Map,
          // return the entire snapshot as a map
          return {
            for (var entry in (snapshot.value as Map).entries)
              entry.key.toString(): entry.value
          };
        }
      } else {
        // Return an empty map if there's no data
        return {};
      }
    } on Exception catch (e) {
      throw DatabaseFailure('$e');
    }
  }
  // Internal helper function to get the DatabaseEvent
  Future<DatabaseEvent> _getDatabaseEventInternal(String collectionName,
      QueryConstraint? constraint, String? queryValue) async {
    switch (constraint) {
      case QueryConstraint.equalToKey:
        return await _database
            .ref(collectionName)
            .orderByKey()
            .equalTo(queryValue)
            .once();
      case QueryConstraint.equalToId:
        return await _database
            .ref(collectionName)
            .orderByChild(QueryConstraint.equalToId.by)
            .equalTo(queryValue)
            .once();
      case QueryConstraint.equalToUserId:
        return await _database
            .ref(collectionName)
            .orderByChild(QueryConstraint.equalToUserId.by)
            .equalTo(queryValue)
            .once();
      case QueryConstraint.equalToUserEmail:
        return await _database
            .ref(collectionName)
            .orderByChild(QueryConstraint.equalToUserEmail.by)
            .equalTo(queryValue)
            .once();
      case QueryConstraint.equalToUserGroup:
        return await _database
            .ref(collectionName)
            .orderByChild(QueryConstraint.equalToUserGroup.by)
            .equalTo(queryValue)
            .once();
      case QueryConstraint.equalToOrganization:
        return await _database
            .ref(collectionName)
            .orderByChild(QueryConstraint.equalToOrganization.by)
            .equalTo(queryValue)
            .once();
      default:
        return await _database.ref(collectionName).orderByKey().once();
    }
  }

  Future<DataSnapshot> _getDatabaseSnapshotInternal(String collectionName,
      QueryConstraint? constraint, String? queryValue) async {
    switch (constraint) {
      case QueryConstraint.equalToKey:
        return await _database
            .ref(collectionName)
            .orderByKey()
            .equalTo(queryValue)
            .get();
      case QueryConstraint.equalToId:
        return await _database
            .ref(collectionName)
            .orderByChild(QueryConstraint.equalToId.by)
            .equalTo(queryValue)
            .get();
      case QueryConstraint.equalToUserId:
        return await _database
            .ref(collectionName)
            .orderByChild(QueryConstraint.equalToUserId.by)
            .equalTo(queryValue)
            .get();
      case QueryConstraint.equalToUserEmail:
        return await _database
            .ref(collectionName)
            .orderByChild(QueryConstraint.equalToUserEmail.by)
            .equalTo(queryValue)
            .get();
      case QueryConstraint.equalToUserGroup:
        return await _database
            .ref(collectionName)
            .orderByChild(QueryConstraint.equalToUserGroup.by)
            .equalTo(queryValue)
            .get();
      case QueryConstraint.equalToOrganization:
        return await _database
            .ref(collectionName)
            .orderByChild(QueryConstraint.equalToOrganization.by)
            .equalTo(queryValue)
            .get();
      default:
        return await _database.ref(collectionName).orderByKey().get();
    }
  }
}