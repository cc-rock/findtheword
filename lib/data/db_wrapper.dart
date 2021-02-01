abstract class DbWrapper {

  /*
  Database values can have the following types:
  String, int, double, bool, List<dynamic> (json array), Map<String, dynamic> (json object)
   */

  Stream<dynamic> onValue(String path);

  Future<dynamic> once(String path);

  Future<void> set(String path, dynamic value);

  Future<void> update(String parentPath, Map<String, dynamic> updates);

  String generateKey(String path);

}