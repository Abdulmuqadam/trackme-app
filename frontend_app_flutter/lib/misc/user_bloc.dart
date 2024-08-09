// user_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

enum UserType { normalUser, facilitatorUser }

class UserBloc extends Cubit<UserType> {
  UserBloc() : super(UserType.normalUser);

  void toggleUserType() {
    emit(state == UserType.normalUser
        ? UserType.normalUser
        : UserType.facilitatorUser);
  }
}
