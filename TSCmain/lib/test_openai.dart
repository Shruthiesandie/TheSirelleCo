import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;

  print("Sending request...");

  final response = await OpenAI.instance.chat.create(
    model: "gpt-4o-mini",
    messages: [
      ChatMessage(
        role: ChatMessageRole.user,
        content: [
          MessageContent.text("Say hello to Vishruth!")
        ],
      )
    ],
  );

  print("Response:");
  print(response.choices.first.message.content!.first.text);
}
