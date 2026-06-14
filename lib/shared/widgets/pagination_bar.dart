import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChange;
  final bool isLoading;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChange,
    this.isLoading = false,
  });

  int get totalPages =>
      totalItems == 0 ? 1 : ((totalItems + pageSize - 1) ~/ pageSize);

  int get _rangeStart => totalItems == 0 ? 0 : (currentPage - 1) * pageSize + 1;
  int get _rangeEnd {
    final end = currentPage * pageSize;
    return end > totalItems ? totalItems : end;
  }

  List<int?> _buildChips() {
    final total = totalPages;
    if (total <= 7) {
      return List<int?>.generate(total, (i) => i + 1);
    }

    final pages = <int>{1, total, currentPage};
    if (currentPage - 1 > 1) pages.add(currentPage - 1);
    if (currentPage + 1 < total) pages.add(currentPage + 1);

    final sorted = pages.toList()..sort();
    final out = <int?>[];
    for (int i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) out.add(null);
      out.add(sorted[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (totalItems <= pageSize) return const SizedBox.shrink();

    final amiri = GoogleFonts.amiri();
    final canGoPrev = !isLoading && currentPage > 1;
    final canGoNext = !isLoading && currentPage < totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.neutral800, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _ChevronButton(
            icon: Icons.chevron_left_rounded,
            enabled: canGoPrev,
            onTap: () => onPageChange(currentPage - 1),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (final token in _buildChips())
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: token == null
                          ? const _GapDots()
                          : _PageChip(
                              page: token,
                              isActive: token == currentPage,
                              isLoading: isLoading,
                              onTap: () => onPageChange(token),
                            ),
                    ),

                  const SizedBox(width: 20),

                  Text(
                    '$_rangeStart - $_rangeEnd  من  $totalItems',
                    style: amiri.copyWith(
                      fontSize: 12,
                      color: AppColors.neutral500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          _ChevronButton(
            icon: Icons.chevron_right_rounded,
            enabled: canGoNext,
            onTap: () => onPageChange(currentPage + 1),
          ),
        ],
      ),
    );
  }
}

class _ChevronButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ChevronButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.3,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cardDark.withAlpha(140),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.neutral800, width: 1),
            ),
            child: Icon(icon, size: 20, color: AppColors.neutral300),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page chip — number pill, midblue accent when it's the current page
// ─────────────────────────────────────────────────────────────────────────────

class _PageChip extends StatelessWidget {
  final int page;
  final bool isActive;
  final bool isLoading;
  final VoidCallback onTap;

  const _PageChip({
    required this.page,
    required this.isActive,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final poppins = GoogleFonts.poppins();
    final fg = isActive ? Colors.white : AppColors.neutral300;
    final bg = isActive ? AppColors.midBlue : AppColors.cardDark.withAlpha(140);
    final border = isActive ? AppColors.midBlue : AppColors.neutral800;

    return Opacity(
      opacity: isLoading && !isActive ? 0.5 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isLoading || isActive) ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minWidth: 36),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: 1),
            ),
            child: Text(
              '$page',
              style: poppins.copyWith(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gap dots — visual "…" between non-adjacent chips
// ─────────────────────────────────────────────────────────────────────────────

class _GapDots extends StatelessWidget {
  const _GapDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 36,
      child: Center(
        child: Text(
          '…',
          style: GoogleFonts.amiri(
            fontSize: 16,
            color: AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
