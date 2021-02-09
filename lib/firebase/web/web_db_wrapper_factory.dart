import 'package:findtheword/firebase/db_wrapper.dart';
import 'package:findtheword/firebase/web/web_db_wrapper.dart';
import 'package:firebase/firebase.dart';

class DbWrapperFactory {

  static DbWrapper getDbWrapper() => WebDbWrapper(database());

}