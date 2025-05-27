import 'package:hive/hive.dart';

part 'story.g.dart';

@HiveType(typeId: 1)
class Story extends HiveObject {
  @HiveField(0)
  final String prompt;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime timestamp;

  Story({required this.prompt, required this.content, required this.timestamp});
}
