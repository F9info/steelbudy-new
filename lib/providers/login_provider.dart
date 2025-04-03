import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  final bool isLoggedIn;

  LoginState({required this.isLoggedIn});
}

class LoginStateNotifier extends StateNotifier<LoginState> {
  LoginStateNotifier() : super(LoginState(isLoggedIn: false));

  void login() {
    state = LoginState(isLoggedIn: true);
  }

  void logout() {
    state = LoginState(isLoggedIn: false);
  }
}

final loginStateProvider =
    StateNotifierProvider<LoginStateNotifier, LoginState>(
  (ref) => LoginStateNotifier(),
);
