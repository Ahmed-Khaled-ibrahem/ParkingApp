import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  FirebaseAuth auth = FirebaseAuth.instance;



  AuthBloc() : super(AuthInitial()) {
    on<AuthEvent>((event, emit) {});

    // print("start auth bloc");
    // auth.authStateChanges()
    //     .listen((User? user) {
    //   if (user == null) {
    //     print('User is currently signed out!');
    //   } else {
    //     print('User is signed in!');
    //   }
    // });

    on<SignInClickEvent>((event, emit) {
      emit(AuthLoading());

    });


  }

  void init() {
    print('start init');
    if (auth.currentUser != null) {
      print('there is user');
      print(state);
      emit(AuthSignInComplete());
      print(auth.currentUser!.uid);
      print(state);
    } else {
      print('there is no user');
    }
  }

  void doEmit(state) {
    emit(state);
  }



}
