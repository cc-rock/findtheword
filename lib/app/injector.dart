import 'package:findtheword/data/db_wrapper_factory.dart'
    if (dart.library.io) 'package:findtheword/data/mobile/mobile_db_wrapper_factory.dart'
    if (dart.library.js) 'package:findtheword/data/web/web_db_wrapper_factory.dart';
import 'package:findtheword/data/repository.dart';

class Injector {

  Repository repository;

  Injector() {
    repository = Repository(DbWrapperFactory.getDbWrapper());
  }

}