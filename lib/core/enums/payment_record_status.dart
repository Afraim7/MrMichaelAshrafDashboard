/// Persisted state of a payment record in the `payments` collection.
/// Reflects the lifecycle of a charge after the gateway result has settled.
enum PaymentRecordStatus { pending, success, failed, refunded }
