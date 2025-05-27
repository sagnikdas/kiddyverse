import 'package:hive/hive.dart';

class Preferences {
  static String? getDefaultChildId() {
    final prefsBox = Hive.box<String>('prefsBox');
    return prefsBox.get('defaultChildId');
  }
}
