import 'package:findtheword/firebase/mobile/mobile_db_wrapper.dart';
import 'package:findtheword/firebase/db_wrapper.dart';
import 'package:firebase_database/firebase_database.dart';

class DbWrapperFactory {

  static DbWrapper getDbWrapper() => MobileDbWrapper(FirebaseDatabase.instance);

}