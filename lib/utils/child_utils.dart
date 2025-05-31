import 'package:hive/hive.dart';
import 'package:kiddyverse/models/child_profile.dart';

ChildProfile? getDefaultChild() {
  final prefsBox = Hive.box<String>('prefsBox');
  final childBox = Hive.box<ChildProfile>('childrenBox');

  final defaultId = prefsBox.get('defaultChildId');
  if (defaultId != null) {
    return childBox.get(defaultId);
  }
  return null;
}
