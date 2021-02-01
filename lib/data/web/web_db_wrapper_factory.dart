import 'package:findtheword/data/db_wrapper.dart';
import 'package:findtheword/data/web/web_db_wrapper.dart';
import 'package:firebase/firebase.dart';

class DbWrapperFactory {

  static DbWrapper getDbWrapper() => WebDbWrapper(database());

}