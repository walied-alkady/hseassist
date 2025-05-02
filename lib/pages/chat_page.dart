// ignore_for_file: unused_import

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../blocs/home_bloc.dart';
import '../enums/chat_type.dart';
import '../models/auth_user_chat.dart';
import '../models/models.dart';
import '../repository/logging_reprository.dart';
import '../service/authentication_service.dart';
import '../widgets/shimmer_loading.dart';


class ChatPage extends StatefulWidget {
  final String chatId;
  final ChatType chatType;
  final ScrollController? scrollController;
  final AuthUser? user;
  final ChatGroup? group;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.chatType,
    this.scrollController,
    this.user,
    this.group,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _log = LoggerReprository('ChatPage');
  final TextEditingController _messageController = TextEditingController();
  late final ScrollController _scrollController;
  


  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController(); // Initialize scroll controller
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.hasClients && _scrollController.position.atEdge && _scrollController.position.pixels == 0) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener); // Remove the listener before disposing
    _scrollController.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_getChatTitle(context)), // Get title based on chat type
      ),
      body: Column(
        children: [
          Expanded(
            child: _createMessageList(context, _scrollController),
          ),
          _createSendMessageArea(context, cubit),
        ],
      ),
    );
  }

  String _getChatTitle(BuildContext context) {
    switch (widget.chatType) {
      case ChatType.ai:
        return 'HSE Assist';
      case ChatType.user:
        return widget.user?.displayName ?? 'User Name';
      case ChatType.group:
        return widget.group?.name ?? 'Group Name';
      case ChatType.none:
        return '';
    }
  }

  Widget _createMessageList(BuildContext context, ScrollController scrollController) {
    return BlocBuilder<HomeCubit, HomePageState>(
      
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();
        List<ChatMessage> messages = state.messages;
        messages.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
        messages = messages.reversed.toList();
        if (state.loadingMessages) {
          return const Center(child: CircularProgressIndicator());
        } else if (messages.isEmpty) {
          return Center(child: Text("noMessages".tr()));
        } else {
          return ListView.builder(
            controller: scrollController,
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isMe = message.senderId == cubit.prefs.currentUserId;

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: message.isLoading // Conditionally add the loading indicator to the message
                    ? _buildLoadingIndicator()
                    : _buildMessageBubble(message, isMe),
              );
            },
            cacheExtent: 2000,
          );
        }
      },
    );
  }
  
  Widget _buildLoadingIndicator() {
    return const SizedBox( // Or use a Shimmer effect here
      height: 20,  // Adjust height as needed
      width: 80,   // Adjust width as needed
      child: Center(child: ShimmerLoading()),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column( // Use a Column to arrange content and timestamp
      crossAxisAlignment: CrossAxisAlignment.end, // Align timestamp to the end
      children: [
        Text(message.content),
        const SizedBox(height: 4), // Small spacing between content and time
        Text(
          _formatTimestamp(message.timestamp??DateTime.now()), // Format the timestamp
          style: TextStyle(fontSize: 12, color: isMe ? Colors.white:Colors.grey), // Style as needed
        ),
      ],
    ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('MMM d').format(timestamp); // Show date if older than a day
    } else if (difference.inHours > 0) {
      return DateFormat('h:mm a').format(timestamp); // Show time if older than an hour
    } else {
      return DateFormat('h:mm a').format(timestamp); // Show time for recent messages
    }
  }
  
  Widget _createSendMessageArea(BuildContext context, HomeCubit cubit) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (text) => _sendMessage(cubit, text),
              decoration: const InputDecoration(
                hintText: 'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(cubit, _messageController.text),
          ),
        ],
      ),
    );
  }

  void _sendMessage(HomeCubit cubit, String text) {

    if (text.isNotEmpty) {
      try {
        if (widget.chatType == ChatType.ai) {
          cubit.sendChatMessage(text);
        } else if (widget.chatType == ChatType.user) {
          cubit.sendUserMessage(widget.chatId, text);
        } else if (widget.chatType == ChatType.group) {
          cubit.sendGroupMessage(widget.chatId, text);
        }
      } catch (e) {
        _log.e('_sendMessage: $e');
      }


      _messageController.clear();
    }
  }
}
