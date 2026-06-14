import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_gateway.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_record_status.dart';

class PaymentRecord {
  final String paymentID;
  final String userID;
  final String courseID;
  final String? enrollmentID;
  final double amount;
  final String currency;
  final PaymentGateway paymentGateway;
  final String paymentMethod;
  final String transactionID;
  final PaymentRecordStatus status;
  final DateTime paidAt;
  final DateTime createdAt;

  PaymentRecord({
    required this.paymentID,
    required this.userID,
    required this.courseID,
    this.enrollmentID,
    required this.amount,
    this.currency = 'EGP',
    required this.paymentGateway,
    required this.paymentMethod,
    required this.transactionID,
    this.status = PaymentRecordStatus.pending,
    required this.paidAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentID': paymentID,
      'userID': userID,
      'courseID': courseID,
      'enrollmentID': enrollmentID,
      'amount': amount,
      'currency': currency,
      'paymentGateway': paymentGateway.name,
      'paymentMethod': paymentMethod,
      'transactionID': transactionID,
      'status': status.name,
      'paidAt': paidAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      paymentID: map['paymentID'] ?? '',
      userID: map['userID'] ?? '',
      courseID: map['courseID'] ?? '',
      enrollmentID: map['enrollmentID'],
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'EGP',
      paymentGateway: PaymentGateway.values.firstWhere(
        (e) => e.name == map['paymentGateway'],
        orElse: () => PaymentGateway.paymob,
      ),
      paymentMethod: map['paymentMethod'] ?? '',
      transactionID: map['transactionID'] ?? '',
      status: PaymentRecordStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentRecordStatus.pending,
      ),
      paidAt: _parseDateTime(map['paidAt']) ?? DateTime.now(),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
    );
  }

  PaymentRecord copyWith({
    String? paymentID,
    String? userID,
    String? courseID,
    String? enrollmentID,
    double? amount,
    String? currency,
    PaymentGateway? paymentGateway,
    String? paymentMethod,
    String? transactionID,
    PaymentRecordStatus? status,
    DateTime? paidAt,
    DateTime? createdAt,
  }) {
    return PaymentRecord(
      paymentID: paymentID ?? this.paymentID,
      userID: userID ?? this.userID,
      courseID: courseID ?? this.courseID,
      enrollmentID: enrollmentID ?? this.enrollmentID,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionID: transactionID ?? this.transactionID,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String toJson() => json.encode(toMap());
  factory PaymentRecord.fromJson(String source) =>
      PaymentRecord.fromMap(json.decode(source));

  bool get isSuccess => status == PaymentRecordStatus.success;
  bool get isPending => status == PaymentRecordStatus.pending;
  bool get isFailed => status == PaymentRecordStatus.failed;
  bool get isRefunded => status == PaymentRecordStatus.refunded;

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentRecord && other.paymentID == paymentID;
  }

  @override
  int get hashCode => paymentID.hashCode;
}
