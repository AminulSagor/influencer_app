class PayoutMethod {
  final String? payoutId;
  final String payoutType;
  final String? bankName;
  final String? accountName;
  final String? accountNo;
  final String? branchName;
  final String? routingNumber;

  final String? bKashNo;
  final String? bKashName;
  final String? bKashAccountType;
  final bool isApproved;

  final bool isBank;

  const PayoutMethod.bank({
    this.payoutId,
    this.payoutType = 'bank',
    required this.bankName,
    required this.accountName,
    required this.accountNo,
    required this.branchName,
    required this.routingNumber,
    this.isApproved = false,
  }) : bKashNo = '',
       bKashName = '',
       bKashAccountType = '',
       isBank = true;

  const PayoutMethod.bKash({
    this.payoutId,
    this.payoutType = 'mobileBanking',
    required this.bKashNo,
    required this.bKashName,
    required this.bKashAccountType,
    this.isApproved = false,
  }) : bankName = '',
       accountName = '',
       accountNo = '',
       branchName = '',
       routingNumber = '',
       isBank = false;
}
