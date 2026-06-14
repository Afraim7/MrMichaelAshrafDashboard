import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCenterCubit extends Cubit<int> {
  DashboardCenterCubit() : super(0);

  void updateScreenIndex(int index) {
    // Range bumped to 5 to make room for the new Payments center.
    if (index != state && index >= 0 && index <= 5) {
      emit(index);
    }
  }

  void navigateToControlPanel() {
    updateScreenIndex(0);
  }

  void navigateToCoursesCenter() {
    updateScreenIndex(1);
  }

  void navigateToExamsCenter() {
    updateScreenIndex(2);
  }

  void navigatetoActiveHighlights() {
    updateScreenIndex(3);
  }

  void navigateToPaymentsCenter() {
    updateScreenIndex(4);
  }

  void navigateToUsersCenter() {
    updateScreenIndex(5);
  }
}