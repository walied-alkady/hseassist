import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'model_base.dart';

part 'chat_message.g.dart';

class ChatMessage extends ModelBase {

  static const collectionString = 'ChatMessage';

  static var empty = ChatMessage(id: '', chatId: '', senderId: '', content: '');

  ///region Getters
  @override
  bool get isEmpty => this == ChatMessage.empty ;
  @override
  bool get isNotEmpty => this != ChatMessage.empty;

  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime? timestamp;
  final String? messageType;
  final String? senderName;
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.timestamp,
    this.messageType,
    this.senderName,
    this.isLoading = false,
  });
  @override
  List<Object?> get props => [id, chatId, senderId, content, timestamp, messageType,senderName];

  @override
  Map<String, dynamic> toMap()=> {
      ChatMessageFields.id.name:id,
      ChatMessageFields.chatId.name:chatId,
      ChatMessageFields.senderId.name:senderId,
      ChatMessageFields.content.name:content,
      ChatMessageFields.createdAt.name:timestamp?.toIso8601String(),
      ChatMessageFields.messageType.name:messageType,
      ChatMessageFields.senderName.name:senderName,

    };
  @override
  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      id: data[ChatMessageFields.id.name] as String,
      chatId: data[ChatMessageFields.chatId.name] as String,
      senderId: data[ChatMessageFields.senderId.name] as String,
      content: data[ChatMessageFields.content.name] as String,
      timestamp:  data[ChatMessageFields.createdAt.name] != null ?(data[ChatMessageFields.createdAt.name] as Timestamp).toDate():null,  // Convert Firestore Timestamp to DateTime if needed
      messageType: data[ChatMessageFields.messageType.name] as String?,
      senderName: data[ChatMessageFields.senderName.name] as String?,
    );
  }
  
  @override
  bool get stringify => true;

  
}

enum ChatMessageFields {
  id, chatId, senderId, content, createdAt, messageType , senderName
}

extension ChatMessageFieldsExtension on ChatMessageFields {
  String get name {
    // Map-based lookup
    return {
      ChatMessageFields.id: 'id',
      ChatMessageFields.chatId: 'chatId',
      ChatMessageFields.senderId: 'senderId',
      ChatMessageFields.content: 'content',
      ChatMessageFields.createdAt: 'timestamp',
      ChatMessageFields.messageType: 'messageType',
      ChatMessageFields.senderName: 'senderName',
    }[this]!; // The ! asserts that the lookup will always find a value.
  }
}
