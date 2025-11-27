import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCenterCubit extends Cubit<int>{
  DashboardCenterCubit() : super(0);

  void updateScreenIndex(int index) {
    if (index != state && index >= 0 && index <= 4) {
      emit(index);
    }
  }

  void navigateToControlPanel() {
    updateScreenIndex(0);
  }

  void navigateToCoursesCenter() {
    updateScreenIndex(1);
  }

  void navigatetoActiveHighlights() {
    updateScreenIndex(2);
  }

  void navigateToExamsCenter() {
    updateScreenIndex(3);
  }

   void navigateToStudentsCenter() {
    updateScreenIndex(4);
  }
}