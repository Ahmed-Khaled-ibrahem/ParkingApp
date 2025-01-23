part of 'app_bloc.dart';

sealed class AppState extends Equatable {
  const AppState();
}

 class AppInitial extends AppState {
  @override
  List<Object> get props => [];
}

 class MapInitial extends AppState {
  @override
  List<Object> get props => [];
}

 class DataChanged extends AppState {
  @override
  List<Object> get props => [];
}

class MyLocationLoaded extends AppState { // working
 @override
 List<Object> get props => [];
}

class NavigationModeOn extends AppState { // working
 @override
 List<Object> get props => [];
}

class NavigationModeOff extends AppState { // working
 @override
 List<Object> get props => [];
}
class LocationUpdated extends AppState { // working
 @override
 List<Object> get props => [];
}
class Refresh1 extends AppState { // working
 @override
 List<Object> get props => [];
}
class Refresh2 extends AppState { // working
 @override
 List<Object> get props => [];
}