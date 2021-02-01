import 'db_wrapper.dart';

class Repository {

  DbWrapper _dbWrapper;

  Repository(this._dbWrapper);

  Stream<List<String>> get stream => _dbWrapper.onValue("testlist").map((value) {
    if (value is Map) {
      return value.values.map((val) => val.toString()).toList();
    } else {
      return ["type", value.runtimeType.toString()];
    }
  });

}