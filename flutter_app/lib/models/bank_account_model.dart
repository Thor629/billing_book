class BankAccount {
  final int? id;
  final int userId;
  final int? organizationId;
  final String accountName;
  final double openingBalance;
  final String asOfDate;
  final String? bankAccountNo;
  final String? ifscCode;
  final String? accountHolderName;
  final String? upiId;
  final String? bankName;
  final String? branchName;
  final double currentBalance;
  final String accountType; // 'bank' or 'cash'
  final String? createdAt;
  final String? updatedAt;

  BankAccount({
    this.id,
    required this.userId,
    this.organizationId,
    required this.accountName,
    required this.openingBalance,
    required this.asOfDate,
    this.bankAccountNo,
    this.ifscCode,
    this.accountHolderName,
    this.upiId,
    this.bankName,
    this.branchName,
    required this.currentBalance,
    this.accountType = 'bank',
    this.createdAt,
    this.updatedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      userId: json['user_id'],
      organizationId: json['organization_id'],
      accountName: json['account_name'],
      openingBalance: double.parse(json['opening_balance'].toString()),
      asOfDate: json['as_of_date'],
      bankAccountNo: json['bank_account_no'],
      ifscCode: json['ifsc_code'],
      accountHolderName: json['account_holder_name'],
      upiId: json['upi_id'],
      bankName: json['bank_name'],
      branchName: json['branch_name'],
      currentBalance: double.parse(json['current_balance'].toString()),
      accountType: json['account_type'] ?? 'bank',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'organization_id': organizationId,
      'account_name': accountName,
      'opening_balance': openingBalance,
      'as_of_date': asOfDate,
      'bank_account_no': bankAccountNo,
      'ifsc_code': ifscCode,
      'account_holder_name': accountHolderName,
      'upi_id': upiId,
      'bank_name': bankName,
      'branch_name': branchName,
      'current_balance': currentBalance,
      'account_type': accountType,
    };
  }
}
