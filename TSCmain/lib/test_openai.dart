import 'package:dart_openai/dart_openai.dart';

void main() async {
  // 1. Set your API key
  OpenAI.apiKey = "";

  // 2. Send a message to OpenAI
  final response = await OpenAI.instance.chat.create(
    model: "gpt-4o-mini",
    messages: [
      ChatMessage(
        role: ChatMessageRole.user,
        content: [
          MessageContent.text("Hello! How are you?")
        ],
      ),
    ],
  );

  // 3. Print the reply
  print(response.choices.first.message.content!.first.text);
}
