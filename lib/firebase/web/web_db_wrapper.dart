import 'package:findtheword/firebase/db_wrapper.dart';
import 'package:firebase/firebase.dart';

class WebDbWrapper extends DbWrapper {

  Database _db;

  WebDbWrapper(this._db);

  @override
  Stream<dynamic> onValue(String path) {
    return _db.ref(path).onValue.map((event) {
      return convertMaps(event.snapshot.val());
    });
  }

  @override
  String generateKey(String path) => _db.ref(path).push().key;

  @override
  Future<dynamic> once(String path) => _db.ref(path).once("value").then(
          (event) => convertMaps(event.snapshot.val())
  );

  @override
  Future<void> set(String path, value) => _db.ref(path).set(value);

  @override
  Future<void> update(String parentPath, Map<String, dynamic> updates) =>
      _db.ref(parentPath).update(updates);

}