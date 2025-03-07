import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/auth_user.dart';

class AuthUserModel extends Equatable {
  final String id;


  const AuthUserModel({
    required this.id,

  });

  factory AuthUserModel.fromFirebaseAuthUser(
    firebase_auth.User firebaseUser,
  ) {
    return AuthUserModel(
      id: firebaseUser.uid,

    );
  }

  // factory AuthUserModel.fromAnotherDataSourceAuthUser(
  //   // ...
  // ) {
  //   return AuthUserModel(
  //     ...
  //   );
  // }

  AuthUser toEntity() {
    return AuthUser(
      id: id,

    );
  }

  @override
  List<Object?> get props => [id];
}
