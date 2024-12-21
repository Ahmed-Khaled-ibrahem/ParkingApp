part of 'app_bloc.dart';

sealed class AppEvent extends Equatable {
  const AppEvent();
}

class StartButtonOnPressed extends AppEvent {
  @override
  List<Object?> get props => [];
}

class loadInitials extends AppEvent {
  @override
  List<Object?> get props => [];
}

class NavigationStarted extends AppEvent {
  @override
  List<Object?> get props => [];
}

class CloseNavigation extends AppEvent {
  @override
  List<Object?> get props => [];
}

class Updater extends AppEvent {
  @override
  List<Object?> get props => [];
}
