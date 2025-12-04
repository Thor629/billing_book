class BankTransaction {
  final int? id;
  final int userId;
  final int? organizationId;
  final int accountId;
  final String
      transactionType; // 'add', 'reduce', 'transfer_out', 'transfer_in'
  final double amount;
  final String transactionDate;
  final String? description;
  final int? relatedAccountId; // For transfers
  final int? relatedTransactionId; // For linking transfer transactions
  final bool isExternalTransfer; // For external transfers
  final String? externalAccountHolder;
  final String? externalAccountNumber;
  final String? externalBankName;
  final String? externalIfscCode;
  final String? createdAt;
  final String? updatedAt;

  BankTransaction({
    this.id,
    required this.userId,
    this.organizationId,
    required this.accountId,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    this.description,
    this.relatedAccountId,
    this.relatedTransactionId,
    this.isExternalTransfer = false,
    this.externalAccountHolder,
    this.externalAccountNumber,
    this.externalBankName,
    this.externalIfscCode,
    this.createdAt,
    this.updatedAt,
  });

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      id: json['id'],
      userId: json['user_id'],
      organizationId: json['organization_id'],
      accountId: json['account_id'],
      transactionType: json['transaction_type'],
      amount: double.parse(json['amount'].toString()),
      transactionDate: json['transaction_date'],
      description: json['description'],
      relatedAccountId: json['related_account_id'],
      relatedTransactionId: json['related_transaction_id'],
      isExternalTransfer: json['is_external_transfer'] ?? false,
      externalAccountHolder: json['external_account_holder'],
      externalAccountNumber: json['external_account_number'],
      externalBankName: json['external_bank_name'],
      externalIfscCode: json['external_ifsc_code'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'organization_id': organizationId,
      'account_id': accountId,
      'transaction_type': transactionType,
      'amount': amount,
      'transaction_date': transactionDate,
      'description': description,
      'related_account_id': relatedAccountId,
      'related_transaction_id': relatedTransactionId,
      'is_external_transfer': isExternalTransfer,
      'external_account_holder': externalAccountHolder,
      'external_account_number': externalAccountNumber,
      'external_bank_name': externalBankName,
      'external_ifsc_code': externalIfscCode,
    };
  }
}
