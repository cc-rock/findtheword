import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserIdRepositoryImpl implements UserIdRepository {
  final FirebaseAuth _firebaseAuth;

  UserIdRepositoryImpl(this._firebaseAuth);

  @override
  Future<String> get currentUserId {
    return _firebaseAuth.currentUser != null ? Future.value(_firebaseAuth.currentUser!.uid)
        : _firebaseAuth.signInAnonymously().then((value) => value.user!.uid);
  }

}