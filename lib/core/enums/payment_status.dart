/// Live result of an in-flight payment session, returned from the gateway
/// (Paymob iframe, callback, etc.) before it settles into a stored record.
enum PaymentStatus { success, failure, pending, cancelled }
