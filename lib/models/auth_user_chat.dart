import '../enums/chat_type.dart';
import 'model_base.dart';

class Chat extends ModelBase {

  static const collectionString = 'AuthUserChat';

  final String id;
  final ChatType  chatType;       // ID of the chat this message belongs to
  final String? name;

  const Chat({
    required this.id,
    required this.chatType,
    required this.name,

  });
  @override
  List<Object?> get props => [id, chatType, name];

  @override
  Map<String, dynamic> toMap()=> {
      ChatFields.id.name:id,
      ChatFields.chatType.name:chatType,
      ChatFields.name.name:name,

    };
  @override
  factory Chat.fromMap(Map<String, dynamic> data) {
    return Chat(
      id: data[ChatFields.id.name] as String,
      chatType: data[ChatFields.chatType.name] as ChatType,
      name: data[ChatFields.name.name] as String,
    );
  }
  
  @override
  // TODO: implement isEmpty
  bool get isEmpty => throw UnimplementedError();
  
  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();

  
}

enum ChatFields {
  id, chatType, name
}
extension ChatFieldsExtension on ChatFields {
  String get name {
    // Map-based lookup
    return {
      ChatFields.id: 'id',
      ChatFields.chatType: 'chatType',
      ChatFields.name: 'name',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}
