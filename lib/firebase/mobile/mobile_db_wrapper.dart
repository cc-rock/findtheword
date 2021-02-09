import 'package:firebase_database/firebase_database.dart';

import '../db_wrapper.dart';

class MobileDbWrapper extends DbWrapper {

  FirebaseDatabase _db;

  MobileDbWrapper(this._db);

  @override
  Stream<dynamic> onValue(String path) {
    return _db.reference().child(path).onValue.map((event) {
      return convertMaps(event.snapshot.value);
    });
  }

  @override
  String generateKey(String path) => _db.reference().child(path).push().key;

  @override
  Future<dynamic> once(String path) => _db.reference().child(path).once().then(
          (snapshot) => convertMaps(snapshot.value)
  );

  @override
  Future<void> set(String path, value) => _db.reference().child(path).set(value);

  @override
  Future<void> update(String parentPath, Map<String, dynamic> updates) =>
      _db.reference().child(parentPath).update(updates);


}