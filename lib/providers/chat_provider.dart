import 'package:flutter/widgets.dart';

class ChatProvider extends ChangeNotifier {
  dynamic recipientsData;
  int conversationId;

  ChatProvider({
    this.recipientsData = const [],
    this.conversationId = 0,
  });

  void changeChat({
    required dynamic newRecipientsData,
    required int newConversationId,
  }) async {
    recipientsData = newRecipientsData;
    conversationId = newConversationId;
    notifyListeners();
  }
}
