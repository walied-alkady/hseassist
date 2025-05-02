import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hseassist/enums/user_role.dart' show UserRole;
import 'package:uuid/uuid.dart'; 
import '../Exceptions/authentication_exception.dart';
import '../Exceptions/database_exception.dart';
import '../blocs/app_bloc.dart';
import '../enums/query_operator.dart';
import '../models/models.dart';
import '../repository/firestore_repository.dart';
import '../repository/logging_reprository.dart';
import 'package:cloud_functions/cloud_functions.dart';


class DatabaseService {
  late final FirestoreRepository _firestore = withEmulator?(FirestoreRepository()..initEmulator()):FirestoreRepository();

  final _log = LoggerReprository('DatabaseService');
  final bool withEmulator;
  String? currentWorkplaceId;
  String? currentRole;
  bool get isCurrentUserMaster => currentUser?.currentWorkplaceRole == UserRole.master.name;
  bool get isAdmin => currentUser?.currentWorkplaceRole == UserRole.admin.name;
  AuthUser? currentUser;

  late final Map<Type, String> collectionName = <Type, String>{ 
          AuthUser: AuthUser.collectionString, 
          Workplace: Workplace.collectionString,
          UserWorkplace: UserWorkplace.collectionString,
          HseMiniSession:HseMiniSession.collectionString,
          ChatMessage: ChatMessage.collectionString,
          Chat: Chat.collectionString,
          WorkplaceSetting: WorkplaceSetting.collectionString,
          WorkplaceLocation:WorkplaceLocation.collectionString,
          WorkplaceInvitation: WorkplaceInvitation.collectionString,
          HseIncident: HseIncident.collectionString,
          HseHazard: HseHazard.collectionString,
          HseTask: HseTask.collectionString,
        };
  
  final HttpsCallable _joinWorkplaceCallable = FirebaseFunctions.instance.httpsCallable('joinWorkplace'); // Create callable object
  final HttpsCallable _createWorkplaceInvitationCallable = FirebaseFunctions.instance.httpsCallable('createWorkplaceInvitation'); // Create callable object
  final HttpsCallable _getUserFromTokenCallable = FirebaseFunctions.instance.httpsCallable('verifyToken');
  final HttpsCallable _registerUserCallable = FirebaseFunctions.instance.httpsCallable('registerUser'); // Create callable object


  DatabaseService({this.withEmulator = false});

  /// **Summery**
  /// 
  /// Registers admin based on [email,passworde]
  /// with optional [firstName,lastName,role,newWorkplaceNam] 
  /// you may enter firstName,lastName or leave them blank
  /// role and newWorkplaceNam in case of new workplace
  /// 
  /// ***Returns***   
  /// 
  /// void
  /// 
  /// ***Throws*** 
  /// 
  /// GeneralAuthenticationFailure
  Future<void> registerAdminUser({
      required String userToken,
      required String email,
      String? firstName,
      String? lastName,
      String? newWorkplaceName,
      String? fcmToken,
    }) async { 
      try {
          _log.i('$userToken, $email, $firstName, $lastName, $newWorkplaceName, $fcmToken');
          final HttpsCallableResult result = await _registerUserCallable.call({
          'idToken': userToken,
          'email':email,
          'firstName':firstName,
          'lastName':lastName,
          'role':'admin',
          'newWorkplaceName':newWorkplaceName,
          'fcmToken':fcmToken,
        });

        if (result.data['status'] == 'success') {
          // Optionally, return userId. Modify the Cloud Function to return it if you need it.

          final currentAuth = await findOneByField<AuthUser>('uid',result.data['userId']);
          if(currentAuth == null) throw UserCreationDBFailure();  
          _log.i('New user created: $email');  

        } else {
          final String errorMessage = result.data['message']; // Get detailed error message from Cloud Function.
          throw UserCreationDBFailure(errorMessage);  //Throw an exception to be caught by the caller
        }
      } on FirebaseFunctionsException catch (e) {
        // Handle Cloud Functions specific errors (e.g., network issues)
        _log.e('Cloud Functions error during registration: ${e.code}, ${e.message}');
        throw UserCreationDBFailure(e.message ?? 'A Cloud Functions error occurred.'); // Re-throw with a more user-friendly message, if needed
      } catch (e) {
        _log.e('Error during user registration: $e'); //Generic exception, mostly our own
        rethrow; // Re-throw to propagate other errors up
      }
    }
  /// **Summery**
  /// 
  /// joins a new user to a workplace based on [invitationCode]
  /// 
  /// ***Returns***   
  /// 
  /// void
  /// 
  /// ***Throws*** 
  /// 
  /// GeneralAuthenticationFailure
  Future<void> joinWorkplace({required String uid,required String invitationCode}) async {
    try {
      final HttpsCallableResult result = await _joinWorkplaceCallable.call({'invitationCode': invitationCode});
      if (result.data['status'] == 'success') {
          // Successfully joined workplace
          _log.i('updating local user data in preferences...');
          final dbUser = await getNewAuthenticatedUser(uid);
          currentWorkplaceId = dbUser?.currentWorkplace;
          if(dbUser == null) throw UserNotFoundFailure();
      } else {
        // Handle error (e.g., display an error message)
        String errorMessage = result.data['message'] ?? 'An error occurred.';
        throw GeneralAuthenticationFailure(errorMessage);
      }
    } on FirebaseFunctionsException catch (e) {
      // Handle Cloud Functions specific errors (e.g., network issues)
      _log.e('Cloud Functions error during joining workplace: ${e.code}, ${e.message}');
      throw GeneralAuthenticationFailure(e.message ?? 'A Cloud Functions error occurred.');
    } catch (e) {
      // Handle other potential errors
      _log.e('Error joining workplace: $e'); // Log the error for debugging
      throw GeneralAuthenticationFailure('An error occurred while joining the workplace.'); //Rethrow for caller to handle
    }
  }
  
  // Future<void> loadUserData (String uid) async {
  //   try{
  //       _log.i('checking database user...');
  //       final newUserDb = await findAll<AuthUser>(
  //         query: 'uid',
  //         queryValue: uid
  //         ).then((value) => value.first);
  //       if (newUserDb.isNotEmpty){
  //         _log.i('saving user to preferences...');
  //         final newLocalUser = AuthUser(
  //           id: newUserDb.id,
  //           uid: newUserDb.uid,
  //           provider: ProviderType.password.name,
  //           email: newUserDb.email,
  //           firstName: newUserDb.firstName??'',
  //           lastName: newUserDb.lastName??'',
  //           displayName: newUserDb.displayName??'',
  //           phoneNumber: newUserDb.phoneNumber??'',
  //           photoURL: newUserDb.photoURL??'',
  //         );
  //         //TODO: fix this
  //         await prefs.updateCurrentUser(newLocalUser);
  //         _log.i('logged in as ${newUserDb.email}');
  //         return;
  //       }
  //       else if(provider == ProviderType.google){
  //             _log.i('Not found in db,registering if with google...');
  //             String? userEmail = authUsr.email;
  //             if(userEmail == null){
  //               throw EmailNotFoundFailure();
  //             }
  //             _log.i('creating db user...');
  //             final newUser = AuthUser(
  //               id: '', 
  //               uid: authUsr.uid,
  //               provider: ProviderType.google.name,
  //               email: authUsr.email??'',
  //               displayName: authUsr.displayName,
  //               isEmailVerified: authUsr.emailVerified,
  //               phoneNumber: authUsr.phoneNumber,
  //               photoURL: authUsr.photoURL,
  //             );
  //             final newUserId = await db.create<AuthUser>(newUser);
  //             _log.i('adding new user [id: $newUserId] to preferences...');
  //             await prefs.updateCurrentUser(AuthUser.fromMap(newUser.toMap()));  
  //             _log.i('logged in as ${authUsr.email}');
  //             return;
  //       }else{
  //         throw UserNotFoundFailure();
  //       }

  //     }catch (e) {
  //           throw GeneralAuthenticationFailure('$e');
  //   } 
  // }
  /// Gets the authenticated user's data from the database.
  Future<AuthUser?> getNewAuthenticatedUser(String uid) async {
    try {
      _log.i('getting user with id : $uid');
      final gotUser = await findOneByField<AuthUser>('uid',uid); 
      if(gotUser == null){
        _log.i('getting user with email : ${gotUser?.email}');
        return gotUser;
      }else{
        _log.i('couldnt get user');
        return gotUser;
      }
    } catch (e) {
      _log.e('Error fetching authenticated user: $e');
      return null;
    }
  }
    /// **Summery**
  /// 
  /// Creates workplace inviation [workplaceId,invitedUserEmail,role]
  /// with optional [daysValid] default is 7 days
  /// 
  /// ***Returns***   
  /// 
  /// void
  /// 
  /// ***Throws*** 
  /// 
  /// GeneralAuthenticationFailure
  Future<String?> createWorkplaceInvitation({
    required String invitedUserEmail,
    required String inviterId,
    required String role,
  }) async {
    try {
      final result = await _createWorkplaceInvitationCallable.call({
        'workplaceId': currentWorkplaceId ,
        'invitedUserEmail': invitedUserEmail,
        'inviterId': inviterId,
        'role': role,
      });

      if (result.data['status'] == 'success') {
        return result.data['invitationCode'] as String?;
      } else {
          throw GeneralAuthenticationFailure(result.data['message'] ?? 'Failed to create invitation.');
      }
    } on FirebaseFunctionsException catch (e) {
      _log.e('Cloud Functions error creating invitation: ${e.code}, ${e.message}');
      throw GeneralAuthenticationFailure(e.message ?? 'A Cloud Functions error occurred.');
    } catch (e) {
      _log.e('Error creating invitation: $e');
      throw GeneralAuthenticationFailure('Failed to create invitation.'); // Generic failure
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? collectionStream<T extends ModelBase>({String? path}) {
    late final Map<Type, String> collectionMap = <Type, String>{ 
          AuthUser: AuthUser.collectionString,  
          Workplace: Workplace.collectionString,
          UserWorkplace: UserWorkplace.collectionString,
          HseMiniSession:HseMiniSession.collectionString,
          WorkplaceInvitation: WorkplaceInvitation.collectionString,

          ChatMessage: '${Workplace.collectionString}/$currentWorkplaceId/${ChatMessage.collectionString}',
          Chat: '${Workplace.collectionString}/$currentWorkplaceId/${Chat.collectionString}',
          WorkplaceSetting: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceSetting.collectionString}',
          WorkplaceLocation: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceLocation.collectionString}',
          HseIncident: '${Workplace.collectionString}/$currentWorkplaceId/${HseIncident.collectionString}',
          HseHazard: '${Workplace.collectionString}/$currentWorkplaceId/${HseHazard.collectionString}',
          HseTask: '${Workplace.collectionString}/$currentWorkplaceId/${HseTask.collectionString}',
        };
    final collectionPath = collectionMap[T];
    if(collectionPath == null) throw ColllectionPathFailure();
    try {
      return _firestore.quaryCollectionStream(collectionPath);
    } catch (e) {
      // Handle errors (e.g., log the error)
      _log.e("Error getting collection stream: $e");  // Or use your logger
      return null; // Or throw an exception depending on your error handling strategy
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? documentStream<T extends ModelBase>(String documentId) {
    try {
      late final Map<Type, String> collectionMap = <Type, String>{ 
          AuthUser: AuthUser.collectionString,  
          Workplace: Workplace.collectionString,
          UserWorkplace: UserWorkplace.collectionString,
          HseMiniSession:HseMiniSession.collectionString,
          WorkplaceInvitation: WorkplaceInvitation.collectionString,

          ChatMessage: '${Workplace.collectionString}/$currentWorkplaceId/${ChatMessage.collectionString}',
          Chat: '${Workplace.collectionString}/$currentWorkplaceId/${Chat.collectionString}',
          WorkplaceSetting: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceSetting.collectionString}',
          WorkplaceLocation: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceLocation.collectionString}',
          HseIncident: '${Workplace.collectionString}/$currentWorkplaceId/${HseIncident.collectionString}',
          HseHazard: '${Workplace.collectionString}/$currentWorkplaceId/${HseHazard.collectionString}',
          HseTask: '${Workplace.collectionString}/$currentWorkplaceId/${HseTask.collectionString}',
        };
      if (documentId.isEmpty) {
        _log.e("Document ID is null or empty, returning null stream");
        return null; // Or throw an exception if you prefer
      }
      final collectionPath = collectionMap[T];
      if(collectionPath == null) throw ColllectionPathFailure();
      return _firestore.quaryDocumentStream(collectionPath, documentId );
      } catch (e) {
        _log.e("Error getting document stream: $e");
        return null; // Or handle the error as needed
      }
  }
  /// Generic create method for any ModelBase subclass.
  Future<String?> create<T extends ModelBase>(T model) async {
    late final Map<Type, String> collectionMap = <Type, String>{ 
          AuthUser: AuthUser.collectionString,  
          Workplace: Workplace.collectionString,
          UserWorkplace: UserWorkplace.collectionString,
          HseMiniSession:HseMiniSession.collectionString,
          WorkplaceInvitation: WorkplaceInvitation.collectionString,

          ChatMessage: '${Workplace.collectionString}/$currentWorkplaceId/${ChatMessage.collectionString}',
          Chat: '${Workplace.collectionString}/$currentWorkplaceId/${Chat.collectionString}',
          WorkplaceSetting: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceSetting.collectionString}',
          WorkplaceLocation: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceLocation.collectionString}',
          HseIncident: '${Workplace.collectionString}/$currentWorkplaceId/${HseIncident.collectionString}',
          HseHazard: '${Workplace.collectionString}/$currentWorkplaceId/${HseHazard.collectionString}',
          HseTask: '${Workplace.collectionString}/$currentWorkplaceId/${HseTask.collectionString}',
        };
    if( currentWorkplaceId ==null && 
      (model.isHseHazard || model.isHseIncident || model.isHseTask  || model.isWorkplaceLocation)
    ){
      throw NoWorkplaceFailure();
    }
    if (model.isAuthUser) {
      return _createUser(model as AuthUser);
    }
    else if (model is WorkplaceInvitation) {
      return _createInvCode(model); 
    }else {
      return _firestore.add(collectionMap[T]!, model.toMap());
    }
  }
  /// Generic create method for any ModelBase subclasses.
  Future<void> createMultiple<T extends ModelBase>(List<T> models) async {
    late final Map<Type, String> collectionMap = <Type, String>{ 
          AuthUser: AuthUser.collectionString,  
          Workplace: Workplace.collectionString,
          UserWorkplace: UserWorkplace.collectionString,
          HseMiniSession:HseMiniSession.collectionString,
          WorkplaceInvitation: WorkplaceInvitation.collectionString,

          ChatMessage: '${Workplace.collectionString}/$currentWorkplaceId/${ChatMessage.collectionString}',
          Chat: '${Workplace.collectionString}/$currentWorkplaceId/${Chat.collectionString}',
          WorkplaceSetting: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceSetting.collectionString}',
          WorkplaceLocation: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceLocation.collectionString}',
          HseIncident: '${Workplace.collectionString}/$currentWorkplaceId/${HseIncident.collectionString}',
          HseHazard: '${Workplace.collectionString}/$currentWorkplaceId/${HseHazard.collectionString}',
          HseTask: '${Workplace.collectionString}/$currentWorkplaceId/${HseTask.collectionString}',
        };
    final model = models.first;
    if( currentWorkplaceId ==null && 
      (model.isHseHazard || model.isHseIncident || model.isHseTask  || model.isWorkplaceLocation)
    ){
      throw NoWorkplaceFailure();
    }
    if (model.isAuthUser) {
      return _createUsers(model as List<AuthUser>);
    }
    else {
      final List<Map<String, dynamic>> dataMaps = models.map((model) => model.toMap()).toList();
      return _firestore.addMultiple(collectionMap[T]!, dataMaps);
    }
  }
  ///create invitation code
  Future<String?> _createInvCode(WorkplaceInvitation inv)async{
    final uuid = const Uuid().v4(); // Generate a UUID
    final expiryDate = Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))); 
    await _firestore.add(WorkplaceInvitation.collectionString, {
                                        // ... other invitation fields
                                        'invitationCode': uuid,
                                        'expiryDate': expiryDate,
                                      });
    return uuid;
  }
  /// Handles AuthUser creation, accounting for different roles.
  Future<String?> _createUser(AuthUser user) async {
    return _firestore.add( AuthUser.collectionString, user.toMap());    
  }
  /// Handles AuthUser creation, accounting for different roles.
  Future<void> _createUsers(List<AuthUser> users) async {
    final List<Map<String, dynamic>> usersMaps = users.map((model) => model.toMap()).toList();
    _firestore.addMultiple(AuthUser.collectionString, usersMaps);    
  }
  /// Generic update method.
  Future<void> updateOne<T extends ModelBase>(String id,Map<String,dynamic> values) async {
      late final Map<Type, String> collectionMap = <Type, String>{ 
          AuthUser: AuthUser.collectionString,  
          Workplace: Workplace.collectionString,
          UserWorkplace: UserWorkplace.collectionString,
          HseMiniSession:HseMiniSession.collectionString,
          WorkplaceInvitation: WorkplaceInvitation.collectionString,

          ChatMessage: '${Workplace.collectionString}/$currentWorkplaceId/${ChatMessage.collectionString}',
          Chat: '${Workplace.collectionString}/$currentWorkplaceId/${Chat.collectionString}',
          WorkplaceSetting: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceSetting.collectionString}',
          WorkplaceLocation: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceLocation.collectionString}',
          HseIncident: '${Workplace.collectionString}/$currentWorkplaceId/${HseIncident.collectionString}',
          HseHazard: '${Workplace.collectionString}/$currentWorkplaceId/${HseHazard.collectionString}',
          HseTask: '${Workplace.collectionString}/$currentWorkplaceId/${HseTask.collectionString}',
        };
      if((T is HseHazard || T is  HseIncident || T is  HseTask) && currentWorkplaceId == null) throw NoWorkplaceFailure();
      String? coll = collectionMap[T]; 
      if(coll == null) throw ColllectionPathFailure();
      await _firestore.update(collectionMap[T]!, id, values);
  }
  /// Generic delete method.
  Future<void> deleteOne<T extends ModelBase>(String id) async {
    late final Map<Type, String> collectionMap = <Type, String>{ 
          AuthUser: AuthUser.collectionString,  
          Workplace: Workplace.collectionString,
          UserWorkplace: UserWorkplace.collectionString,
          HseMiniSession:HseMiniSession.collectionString,
          WorkplaceInvitation: WorkplaceInvitation.collectionString,

          ChatMessage: '${Workplace.collectionString}/$currentWorkplaceId/${ChatMessage.collectionString}',
          Chat: '${Workplace.collectionString}/$currentWorkplaceId/${Chat.collectionString}',
          WorkplaceSetting: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceSetting.collectionString}',
          WorkplaceLocation: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceLocation.collectionString}',
          HseIncident: '${Workplace.collectionString}/$currentWorkplaceId/${HseIncident.collectionString}',
          HseHazard: '${Workplace.collectionString}/$currentWorkplaceId/${HseHazard.collectionString}',
          HseTask: '${Workplace.collectionString}/$currentWorkplaceId/${HseTask.collectionString}',
        };
    String? coll = collectionMap[T]; 
    if(coll == null) throw ColllectionPathFailure(); 
    await _firestore.remove(coll, id);
  }
  /// Generic find method by doc id.
  Future<T?> findOne<T extends ModelBase>(String docId) async {
    late final Map<Type, String> collectionMap = <Type, String>{ 
          AuthUser: AuthUser.collectionString,  
          Workplace: Workplace.collectionString,
          UserWorkplace: UserWorkplace.collectionString,
          HseMiniSession:HseMiniSession.collectionString,
          WorkplaceInvitation: WorkplaceInvitation.collectionString,

          ChatMessage: '${Workplace.collectionString}/$currentWorkplaceId/${ChatMessage.collectionString}',
          Chat: '${Workplace.collectionString}/$currentWorkplaceId/${Chat.collectionString}',
          WorkplaceSetting: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceSetting.collectionString}',
          WorkplaceLocation: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceLocation.collectionString}',
          HseIncident: '${Workplace.collectionString}/$currentWorkplaceId/${HseIncident.collectionString}',
          HseHazard: '${Workplace.collectionString}/$currentWorkplaceId/${HseHazard.collectionString}',
          HseTask: '${Workplace.collectionString}/$currentWorkplaceId/${HseTask.collectionString}',
        };
    String? coll = collectionMap[T]; 
    if(coll == null) throw ColllectionPathFailure();
    String? collName = collectionName[T]; 
    if(collName == null) throw ColllectionPathFailure();
    final doc = await _firestore.getDocumentSnapShot(coll,docId);
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return ModelBase.createModel(collName,data) as T;
    }
    return null;
  }
  /// Generic find method by doc id.
  Future<T?> findOneByField<T extends ModelBase>(dynamic field,dynamic queryValue,{QueryComparisonOperator quaryOperator = QueryComparisonOperator.eq}) async {
    late final Map<Type, String> collectionMap = <Type, String>{ 
          AuthUser: AuthUser.collectionString,  
          Workplace: Workplace.collectionString,
          UserWorkplace: UserWorkplace.collectionString,
          HseMiniSession:HseMiniSession.collectionString,
          WorkplaceInvitation: WorkplaceInvitation.collectionString,

          ChatMessage: '${Workplace.collectionString}/$currentWorkplaceId/${ChatMessage.collectionString}',
          Chat: '${Workplace.collectionString}/$currentWorkplaceId/${Chat.collectionString}',
          WorkplaceSetting: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceSetting.collectionString}',
          WorkplaceLocation: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceLocation.collectionString}',
          HseIncident: '${Workplace.collectionString}/$currentWorkplaceId/${HseIncident.collectionString}',
          HseHazard: '${Workplace.collectionString}/$currentWorkplaceId/${HseHazard.collectionString}',
          HseTask: '${Workplace.collectionString}/$currentWorkplaceId/${HseTask.collectionString}',
        };
    String? coll = collectionMap[T];
    if(coll == null) throw ColllectionPathFailure();
    String? collName = collectionName[T]; 
    if(collName == null) throw ColllectionPathFailure();
    final querySnapshot = await _firestore.quarySnapshot(coll,field,queryValue,quaryOperator: quaryOperator);
    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs[0].data();
      return ModelBase.createModel(collName,data) as T;
    }
    return null;
  }
  // findAll method, shared logic as in create, update, etc.
  Future<List<T>> findAll<T extends ModelBase>({
      String? query,
      QueryComparisonOperator? quaryOperator,
      dynamic queryValue,
      String? orderBy,
      bool? isDescending,
      }) async {
      late final Map<Type, String> collectionMap = <Type, String>{ 
            AuthUser: AuthUser.collectionString,  
            Workplace: Workplace.collectionString,
            UserWorkplace: UserWorkplace.collectionString,
            HseMiniSession:HseMiniSession.collectionString,
            WorkplaceInvitation: WorkplaceInvitation.collectionString,

            ChatMessage: '${Workplace.collectionString}/$currentWorkplaceId/${ChatMessage.collectionString}',
            Chat: '${Workplace.collectionString}/$currentWorkplaceId/${Chat.collectionString}',
            WorkplaceSetting: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceSetting.collectionString}',
            WorkplaceLocation: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceLocation.collectionString}',
            HseIncident: '${Workplace.collectionString}/$currentWorkplaceId/${HseIncident.collectionString}',
            HseHazard: '${Workplace.collectionString}/$currentWorkplaceId/${HseHazard.collectionString}',
            HseTask: '${Workplace.collectionString}/$currentWorkplaceId/${HseTask.collectionString}',
          };
      String? coll = collectionMap[T]; 
      if(coll == null) throw ColllectionPathFailure();
      final items = await _firestore.quaryCollection(coll,query,queryValue,quaryOperator: quaryOperator,orderBy: orderBy,isDescending: isDescending);
      String? collName = collectionName[T]; 
      if(collName == null) throw ColllectionPathFailure();
      if(items.docs.isNotEmpty){
        return items.docs.map<T>((entry) {
            final itemData = Map<String, dynamic>.from(entry.data() as Map);
            itemData[ModelBase.idString] = entry.id;
            return ModelBase.createModel(collName,itemData) as T;
        }).toList();
      }else{
        return [];
      }
    }
  ///
  /// var query = FirebaseFirestore.instance.collection("cities").where(
  ///      Filter.or(
  ///        Filter("capital", isEqualTo: true),
  ///        Filter("population", isGreaterThan: 1000000),
  ///      ),
  ///    );
  ///

  Future<List<T>> findAllWithComplexQuery<T extends ModelBase>({
      required Filter queryFilter,
      String? orderBy,
      bool? isDescending,
      }) async {
      late final Map<Type, String> collectionMap = <Type, String>{ 
            AuthUser: AuthUser.collectionString,  
            Workplace: Workplace.collectionString,
            UserWorkplace: UserWorkplace.collectionString,
            HseMiniSession:HseMiniSession.collectionString,
            WorkplaceInvitation: WorkplaceInvitation.collectionString,

            ChatMessage: '${Workplace.collectionString}/$currentWorkplaceId/${ChatMessage.collectionString}',
            Chat: '${Workplace.collectionString}/$currentWorkplaceId/${Chat.collectionString}',
            WorkplaceSetting: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceSetting.collectionString}',
            WorkplaceLocation: '${Workplace.collectionString}/$currentWorkplaceId/${WorkplaceLocation.collectionString}',
            HseIncident: '${Workplace.collectionString}/$currentWorkplaceId/${HseIncident.collectionString}',
            HseHazard: '${Workplace.collectionString}/$currentWorkplaceId/${HseHazard.collectionString}',
            HseTask: '${Workplace.collectionString}/$currentWorkplaceId/${HseTask.collectionString}',
          };
      String? coll = collectionMap[T]; 
      if(coll == null) throw ColllectionPathFailure();
      final items = await _firestore.queryWithFilter(coll, queryFilter);
      String? collName = collectionName[T]; 
      if(collName == null) throw ColllectionPathFailure();
      if(items.docs.isNotEmpty){
        return items.docs.map<T>((entry) {
            final itemData = Map<String, dynamic>.from(entry.data() as Map);
            itemData[ModelBase.idString] = entry.id;
            return ModelBase.createModel(collName,itemData) as T;
        }).toList();
      }else{
        return [];
      }
    }

}
