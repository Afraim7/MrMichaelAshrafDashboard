import 'package:bloc/bloc.dart';
import 'package:mrmichaelashrafdashboard/Features/Splash/Logic/dashboard_flow_state.dart';

class DashboardFlowCubit extends Cubit<DashboardFlowState> {
  DashboardFlowCubit() : super(DashboardFlowChecking());

  Future<void> checkDashboardFlow({
    required bool isLoggedIn,
    required bool isEmailVerified,
  }) async {
    emit(DashboardFlowChecking());

    try {
      if (!isLoggedIn || !isEmailVerified) {
        emit(DashboardFlowAdminLogin());
        return;
      }

      emit(DashboardFlowControlPanel());
    } catch (e) {
      emit(
        DashboardFlowError(
          'حصل خطأ أثناء الدخول إلى لوحة التحكم يرجي التحقق من اتصالك والمحاولة مرة أخرى',
        ),
      );
    }
  }
}
