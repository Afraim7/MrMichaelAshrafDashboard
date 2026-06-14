import 'package:intl/intl.dart';

/// Single place where money becomes a string. Every payment card, analytics
/// chip, and revenue tile should call into one of these helpers — that way
/// changing the currency symbol or precision is a one-line edit instead of a
/// codebase-wide search.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Default Egyptian Pound formatter — `1,250 ج.م`. Uses Arabic grouping
  /// separators and the standard ج.م glyph. Whole pounds render with no
  /// decimals; a fractional amount (e.g. a `7.5` manual/wallet payment)
  /// automatically renders 2dp (`7.50 ج.م`) so it's never silently rounded.
  /// [showDecimals] forces 2dp even for whole amounts.
  static String egp(double amount, {bool showDecimals = false}) {
    final hasFraction = amount != amount.roundToDouble();
    final pattern = (showDecimals || hasFraction) ? '#,##0.00' : '#,##0';
    final f = NumberFormat(pattern, 'ar');
    return '${f.format(amount)} ج.م';
  }

  /// Generic "amount + currency code" formatter used when the [PaymentRecord]
  /// might one day store a non-EGP currency (USD card payments, etc.). Falls
  /// back to the localized symbol when the code is the default 'EGP'.
  static String withCode(double amount, String code) {
    if (code.toUpperCase() == 'EGP') return egp(amount);
    final f = NumberFormat('#,##0.00', 'en');
    return '${f.format(amount)} ${code.toUpperCase()}';
  }

  /// Compact form used in analytics tiles where space is tight, e.g.
  /// `1.2K ج.م` instead of `1,200 ج.م`. Keeps a single decimal for thousands.
  static String compact(double amount) {
    if (amount.abs() < 1000) return egp(amount);
    if (amount.abs() < 1_000_000) {
      return '${(amount / 1000).toStringAsFixed(1)}K ج.م';
    }
    return '${(amount / 1_000_000).toStringAsFixed(1)}M ج.م';
  }
}
