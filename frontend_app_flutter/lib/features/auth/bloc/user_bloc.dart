// user_bloc.dart

import 'package:get/get.dart';

enum UserType { normalUser, facilitatorUser }

class UserController extends GetxController {
  final userType = UserType.normalUser.obs;

  void toggleUserType() {
    userType.value = userType.value == UserType.normalUser
        ? UserType.facilitatorUser
        : UserType.normalUser;
  }
}
