class PaymentMethodExpense {
  const PaymentMethodExpense({
    required this.name,
    required this.total,
    this.paymentMethodId,
  });

  final String name;
  final int total;
  final int? paymentMethodId;
}
