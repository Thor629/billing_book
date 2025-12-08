class Expense {
  final int id;
  final int organizationId;
  final int userId;
  final int? partyId;
  final String expenseNumber;
  final DateTime expenseDate;
  final String category;
  final String paymentMode;
  final int? bankAccountId;
  final double totalAmount;
  final bool withGst;
  final String? notes;
  final String? originalInvoiceNumber;
  final Party? party;
  final BankAccount? bankAccount;
  final List<ExpenseItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.organizationId,
    required this.userId,
    this.partyId,
    required this.expenseNumber,
    required this.expenseDate,
    required this.category,
    required this.paymentMode,
    this.bankAccountId,
    required this.totalAmount,
    required this.withGst,
    this.notes,
    this.originalInvoiceNumber,
    this.party,
    this.bankAccount,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      organizationId: json['organization_id'],
      userId: json['user_id'],
      partyId: json['party_id'],
      expenseNumber: json['expense_number'] ?? '',
      expenseDate: DateTime.parse(json['expense_date']),
      category: json['category'] ?? '',
      paymentMode: json['payment_mode'] ?? '',
      bankAccountId: json['bank_account_id'],
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      withGst: json['with_gst'] ?? false,
      notes: json['notes'],
      originalInvoiceNumber: json['original_invoice_number'],
      party: json['party'] != null ? Party.fromJson(json['party']) : null,
      bankAccount: json['bank_account'] != null
          ? BankAccount.fromJson(json['bank_account'])
          : null,
      items: (json['items'] as List?)
              ?.map((item) => ExpenseItem.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'user_id': userId,
      'party_id': partyId,
      'expense_number': expenseNumber,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
      'category': category,
      'payment_mode': paymentMode,
      'bank_account_id': bankAccountId,
      'total_amount': totalAmount,
      'with_gst': withGst,
      'notes': notes,
      'original_invoice_number': originalInvoiceNumber,
    };
  }
}

class ExpenseItem {
  final int? id;
  final int? expenseId;
  final String itemName;
  final String? description;
  final double amount;
  final double quantity;
  final double rate;

  ExpenseItem({
    this.id,
    this.expenseId,
    required this.itemName,
    this.description,
    required this.amount,
    required this.quantity,
    required this.rate,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'],
      expenseId: json['expense_id'],
      itemName: json['item_name'] ?? '',
      description: json['description'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      rate: double.tryParse(json['rate']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (expenseId != null) 'expense_id': expenseId,
      'item_name': itemName,
      'description': description,
      'amount': amount,
      'quantity': quantity,
      'rate': rate,
    };
  }
}

class Party {
  final int id;
  final String name;
  final String phone;
  final String? partyType;

  Party({
    required this.id,
    required this.name,
    required this.phone,
    this.partyType,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      partyType: json['party_type'],
    );
  }
}

class BankAccount {
  final int id;
  final String accountName;
  final String? bankName;
  final String accountType;
  final double currentBalance;

  BankAccount({
    required this.id,
    required this.accountName,
    this.bankName,
    required this.accountType,
    required this.currentBalance,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      accountName: json['account_name'] ?? '',
      bankName: json['bank_name'],
      accountType: json['account_type'] ?? '',
      currentBalance:
          double.tryParse(json['current_balance']?.toString() ?? '0') ?? 0.0,
    );
  }
}
