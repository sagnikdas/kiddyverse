import 'package:hive/hive.dart';

part 'child_profile.g.dart';

@HiveType(typeId: 0)
class ChildProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int age;

  @HiveField(3)
  final String avatar;

  ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.avatar,
  });
}
