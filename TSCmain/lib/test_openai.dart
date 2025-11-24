import 'package:dart_openai/dart_openai.dart';

void main() async {
  // 1. Set your API key here
  OpenAI.apiKey = "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";

  // 2. Send a message to OpenAI
  final response = await OpenAI.chat.create(
    model: "gpt-4o-mini",
    messages: [
      {"role": "user", "content": "Hello, how are you?"}
    ],
  );

  // 3. Print the response
  print(response.choices.first.message.content);
}
