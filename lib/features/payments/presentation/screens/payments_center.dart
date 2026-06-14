import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/core/config/dashboard_configs.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_spacing.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_gateway.dart';
import 'package:mrmichaelashrafdashboard/features/payments/data/models/payment_record.dart';
import 'package:mrmichaelashrafdashboard/features/payments/logic/payments_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/payments/logic/payments_state.dart';
import 'package:mrmichaelashrafdashboard/features/payments/presentation/widgets/payment_card.dart';
import 'package:mrmichaelashrafdashboard/features/payments/presentation/widgets/payment_sheet.dart';
import 'package:mrmichaelashrafdashboard/shared/dialogs/app_bottom_sheet.dart';
import 'package:mrmichaelashrafdashboard/shared/views/empty_view.dart';
import 'package:mrmichaelashrafdashboard/shared/views/error_view.dart';
import 'package:mrmichaelashrafdashboard/shared/views/loading_view.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/filters.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/pagination_bar.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/responsive_grid.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/screen_top_bar.dart';

/// Read-only payments center. Admins browse + inspect; there are no
/// confirm/reject/refund actions. The center is a thin view over
/// [PaymentsCubit] — the cubit owns the page list, loading, and error state
/// (it has no mutations, so there's no reason to mirror the list locally).
/// Only the active status filter lives here.
class PaymentsCenter extends StatefulWidget {
  const PaymentsCenter({super.key});

  @override
  State<PaymentsCenter> createState() => _PaymentsCenterState();
}

class _PaymentsCenterState extends State<PaymentsCenter> {
  /// `null` = "all". Otherwise the active payment-gateway filter.
  PaymentGateway? _selectedGateway;

  @override
  void initState() {
    super.initState();
    _fetch(page: 1);
  }

  void _fetch({required int page}) {
    context.read<PaymentsCubit>().fetchPaymentsPage(
      page: page,
      pageSize: DashboardConfigs.pageSize,
      gateway: _selectedGateway,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenTopBar(
              title: 'المدفوعات',
              subtitle: 'عرض جميع الدفعات وتفاصيلها',
              actions: const [],
            ),

            // ── Gateway filter (local — the only state the screen owns) ──
            Filters<PaymentGateway?>(
              selectedFilter: _selectedGateway,
              onChanged: (gateway) {
                setState(() => _selectedGateway = gateway);
                _fetch(page: 1);
              },
              items: [
                const FilterItem(
                  value: null,
                  title: 'الكل',
                  color: AppColors.royalBlue,
                ),
                // Only the gateways the platform actually uses — manual,
                // Paymob, Fawry (stripe/paypal intentionally omitted).
                for (final gw in const [
                  PaymentGateway.manual,
                  PaymentGateway.paymob,
                  PaymentGateway.fawry,
                ])
                  FilterItem(
                    value: gw,
                    title: gw.label,
                    icon: gw.icon,
                    color: gw.color,
                  ),
              ],
            ),

            // ── Body + pagination, driven entirely by cubit state ──────
            BlocBuilder<PaymentsCubit, PaymentsState>(
              builder: (context, state) {
                if (state is FetchPaymentsError) {
                  return Padding(
                    padding: AppSpacing.screenBlock,
                    child: ErrorView(
                      message: state.message,
                      animationPath: AppAssets.animations.cart,
                      onRetry: () => _fetch(page: 1),
                    ),
                  );
                }
                if (state is FetchPaymentsSuccess) {
                  return _LoadedBody(
                    state: state,
                    selectedGateway: _selectedGateway,
                    onPageChange: (p) => _fetch(page: p),
                    onOpenSheet: _openPaymentSheet,
                  );
                }
                // Initial + FetchPaymentsLoading.
                return const LoadingView();
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _openPaymentSheet(
    PaymentRecord payment,
    String userName,
    String courseTitle,
  ) {
    // Keep the same cubit available so the read-only sheet can resolve its
    // display data from the same source.
    final cubit = context.read<PaymentsCubit>();
    AppBottomSheet(
      child: BlocProvider.value(
        value: cubit,
        child: PaymentSheet(
          payment: payment,
          userName: userName,
          courseTitle: courseTitle,
        ),
      ),
    ).showBottomSheet(context);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loaded body — grid + pagination bar, rendered from a FetchPaymentsSuccess.
// ─────────────────────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  final FetchPaymentsSuccess state;
  final PaymentGateway? selectedGateway;
  final ValueChanged<int> onPageChange;
  final void Function(PaymentRecord, String, String) onOpenSheet;

  const _LoadedBody({
    required this.state,
    required this.selectedGateway,
    required this.onPageChange,
    required this.onOpenSheet,
  });

  @override
  Widget build(BuildContext context) {
    if (state.payments.isEmpty) {
      return Padding(
        padding: AppSpacing.screenBlock,
        child: EmptyView(
          message: selectedGateway == null
              ? 'لا توجد دفعات حالياً'
              : 'لا توجد دفعات بهذه البوابة',
          animationPath: AppAssets.animations.cart,
        ),
      );
    }

    // Display labels come straight off the cubit's success state — the cubit
    // pre-resolved them with batched whereIn lookups so we don't N+1 here.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveGrid<PaymentRecord>(
          items: state.payments,
          itemBuilder: (context, payment) {
            final userName =
                state.userNamesMap[payment.userID] ?? 'طالب غير معروف';
            final courseTitle =
                state.courseTitlesMap[payment.courseID] ?? payment.courseID;
            return PaymentCard(
              payment: payment,
              userName: userName,
              courseTitle: courseTitle,
              onTap: () => onOpenSheet(payment, userName, courseTitle),
            );
          },
        ),
        PaginationBar(
          currentPage: state.page,
          totalItems: state.totalCount,
          pageSize: state.pageSize,
          onPageChange: onPageChange,
        ),
      ],
    );
  }
}
