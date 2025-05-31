import 'package:hive/hive.dart';

part 'story.g.dart';

@HiveType(typeId: 1)
class Story extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String prompt;

  @HiveField(2)
  final String generatedText;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String childId;

  @HiveField(5)
  final bool isFavorite;

  Story({
    required this.id,
    required this.prompt,
    required this.generatedText,
    required this.timestamp,
    required this.childId,
    this.isFavorite = false,
  });

  Story copyWith({
    String? id,
    String? prompt,
    String? generatedText,
    DateTime? timestamp,
    String? childId,
    bool? isFavorite,
  }) {
    return Story(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      generatedText: generatedText ?? this.generatedText,
      timestamp: timestamp ?? this.timestamp,
      childId: childId ?? this.childId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
