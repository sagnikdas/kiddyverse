import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;

  OpenAIService({required this.apiKey});

  Future<String?> generateStory(String prompt) async {
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      "store": true,
      'messages': [
        {'role': 'system', 'content': 'You are a creative storyteller for young children.'},
        {'role': 'user', 'content': prompt},
      ]
    });

    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final content = json['choices'][0]['message']['content'];
      return content;
    } else {
      print('OpenAI API error: ${response.body}');
      return null;
    }
  }
}
