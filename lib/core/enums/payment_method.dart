enum WalletProvider { vodafoneCash, orangeMoney, etisalatCash }

sealed class PaymentMethod {
  const PaymentMethod();
}

class PaymobMobileWallet extends PaymentMethod {
  final String mobileNumber;
  final WalletProvider provider;
  const PaymobMobileWallet({
    required this.mobileNumber,
    required this.provider,
  });
}
