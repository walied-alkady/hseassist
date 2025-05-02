import 'model_base.dart';

class ChatGroup extends ModelBase {

  static const collectionString = 'hseHazards';

  static const empty = ChatGroup();
  ///region Getters
  ///region Getters
  @override
  bool get isEmpty => this == ChatGroup.empty ;
  @override
  bool get isNotEmpty => this != ChatGroup.empty;


  final String id;
  final String name;
  final String? description; // Optional description
  final List<String> memberIds; // List of user IDs in the group
  final String? creatorId;  // User ID of the group creator (Optional)
  final String createdAt;
  final String? lastMessage;
  final String? lastMessageTime;


  const ChatGroup({
    this.id='',
    this.name='',
    this.description,
    this.memberIds=const [],
    this.creatorId,
    this.createdAt = '',
    this.lastMessage,
    this.lastMessageTime,

  });
  @override
  List<Object?> get props => [id, name, description, memberIds, creatorId,createdAt,lastMessage,lastMessageTime,];

  @override
  Map<String, dynamic> toMap()=> {
      ChatGroupFields.id.name:id,
      ChatGroupFields.name.name:name,
      ChatGroupFields.description.name:description,
      ChatGroupFields.memberIds.name: memberIds,
      ChatGroupFields.creatorId.name: creatorId,
      ChatGroupFields.createdAt.name: createdAt,
      ChatGroupFields.lastMessage.name: lastMessage,
      ChatGroupFields.lastMessageTime.name: lastMessageTime,

    };
  @override
  factory ChatGroup.fromMap(Map<String, dynamic> data) {
    return ChatGroup(
      id: data[ChatGroupFields.id.name] as String,
      name: data[ChatGroupFields.name.name] as String,
      description: data[ChatGroupFields.description.name] as String?,
      memberIds: List<String>.from(data[ChatGroupFields.memberIds.name] as List), 
      creatorId: data[ChatGroupFields.creatorId.name] as String?,
      createdAt: data[ChatGroupFields.createdAt.name] as String,
      lastMessage: data[ChatGroupFields.lastMessage.name] as String?,
      lastMessageTime: data[ChatGroupFields.lastMessageTime.name] as String?,

    );
  }

  
}

enum ChatGroupFields {
  id, name, description, memberIds, creatorId,createdAt,lastMessage,lastMessageTime
}
extension ChatGroupFieldsExtension on ChatGroupFields {
  String get name {
    // Map-based lookup
    return {
      ChatGroupFields.id: 'id',
      ChatGroupFields.name: 'name',
      ChatGroupFields.description: 'description',
      ChatGroupFields.memberIds: 'memberIds',
      ChatGroupFields.creatorId: 'creatorId',
      ChatGroupFields.createdAt: 'createdAt',
      ChatGroupFields.lastMessage: 'lastMessage',
      ChatGroupFields.lastMessageTime: 'lastMessageTime',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}
