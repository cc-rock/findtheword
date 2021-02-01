import 'package:findtheword/data/mobile/mobile_db_wrapper.dart';
import 'package:findtheword/data/db_wrapper.dart';
import 'package:firebase_database/firebase_database.dart';

class DbWrapperFactory {

  static DbWrapper getDbWrapper() => MobileDbWrapper(FirebaseDatabase.instance);

}