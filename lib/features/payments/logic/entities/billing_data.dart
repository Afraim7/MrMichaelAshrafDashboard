class BillingData {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String city;
  final String country;

  BillingData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.city = 'Cairo',
    this.country = 'EG',
  });
}
