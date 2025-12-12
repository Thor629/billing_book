import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/payment_out_service.dart';
import '../../services/party_service.dart';
import '../../services/bank_account_service.dart';
import '../../providers/organization_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/party_model.dart';
import '../../models/bank_account_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/dialog_scaffold.dart';

class CreatePaymentOutScreen extends StatefulWidget {
  final int? paymentId;
  final Map<String, dynamic>? paymentData;

  const CreatePaymentOutScreen({
    super.key,
    this.paymentId,
    this.paymentData,
  });

  @override
  State<CreatePaymentOutScreen> createState() => _CreatePaymentOutScreenState();
}

class _CreatePaymentOutScreenState extends State<CreatePaymentOutScreen> {
  final PaymentOutService _paymentOutService = PaymentOutService();
  final PartyService _partyService = PartyService();
  final BankAccountService _bankAccountService = BankAccountService();

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  List<PartyModel> _parties = [];
  List<BankAccount> _bankAccounts = [];
  int? _selectedPartyId;
  int? _selectedBankAccountId;
  DateTime _paymentDate = DateTime.now();
  String _paymentMethod = 'cash';
  String _paymentNumber = '';
  bool _isLoading = false;
  bool _isSaving = false;

  final List<String> _paymentMethods = [
    'cash',
    'bank_transfer',
    'cheque',
    'card',
    'upi',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    setState(() => _isLoading = true);

    try {
      // Get auth token
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.token;

      if (token == null) {
        throw Exception('No authentication token');
      }

      // Load parties (all parties - filter suppliers)
      final parties = await _partyService.getParties(
        orgProvider.selectedOrganization!.id,
      );

      // Load bank accounts
      final accounts = await _bankAccountService.getBankAccounts(
        token,
        orgProvider.selectedOrganization!.id,
      );

      // Get next payment number
      final nextNumber = await _paymentOutService.getNextPaymentNumber(
        orgProvider.selectedOrganization!.id.toString(),
      );

      debugPrint('🔢 Loaded next payment number: $nextNumber');

      setState(() {
        _parties = parties
            .where((p) => p.partyType == 'vendor' || p.partyType == 'both')
            .toList();
        _bankAccounts = accounts;
        _paymentNumber = nextNumber;
        _isLoading = false;

        // Load existing payment data if in edit mode
        if (widget.paymentData != null) {
          debugPrint('🔄 Loading existing payment data: ${widget.paymentData}');
          _paymentNumber =
              widget.paymentData!['payment_number'] ?? _paymentNumber;
          _selectedPartyId = widget.paymentData!['party_id'];
          _amountController.text =
              widget.paymentData!['amount']?.toString() ?? '';
          _paymentMethod = widget.paymentData!['payment_method'] ?? 'cash';
          _selectedBankAccountId = widget.paymentData!['bank_account_id'];
          _referenceController.text =
              widget.paymentData!['reference_number'] ?? '';
          _notesController.text = widget.paymentData!['notes'] ?? '';
          if (widget.paymentData!['payment_date'] != null) {
            _paymentDate = DateTime.parse(widget.paymentData!['payment_date']);
          }
          debugPrint(
              '✅ Loaded existing payment - Party ID: $_selectedPartyId, Amount: ${_amountController.text}');
        }
      });

      debugPrint('✅ Payment number set in state: $_paymentNumber');
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  bool get _isEditMode =>
      widget.paymentId != null || widget.paymentData != null;

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPartyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a party')),
      );
      return;
    }

    if (_paymentMethod != 'cash' && _selectedBankAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank account')),
      );
      return;
    }

    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    setState(() => _isSaving = true);

    try {
      final paymentData = {
        'organization_id': orgProvider.selectedOrganization!.id,
        'party_id': _selectedPartyId,
        'payment_number': _paymentNumber,
        'payment_date': _paymentDate.toIso8601String().split('T')[0],
        'amount': double.parse(_amountController.text),
        'payment_method': _paymentMethod,
        'status': 'completed',
        if (_selectedBankAccountId != null)
          'bank_account_id': _selectedBankAccountId,
        if (_referenceController.text.isNotEmpty)
          'reference_number': _referenceController.text,
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
      };

      if (_isEditMode && widget.paymentId != null) {
        // Update existing payment
        await _paymentOutService.updatePaymentOut(
          widget.paymentId!,
          paymentData,
        );
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment out updated successfully'),
            ),
          );
        }
      } else {
        // Create new payment
        await _paymentOutService.createPaymentOut(paymentData);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Payment out created and balance updated successfully'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving payment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: _isEditMode ? 'Edit Payment Out' : 'Create Payment Out',
      onSave: _savePayment,
      isSaving: _isSaving,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Number
                    TextFormField(
                      key: ValueKey(_paymentNumber),
                      initialValue: _paymentNumber,
                      decoration: const InputDecoration(
                        labelText: 'Payment Number',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Party Selection
                    DropdownButtonFormField<int>(
                      value: _selectedPartyId,
                      decoration: const InputDecoration(
                        labelText: 'Supplier *',
                        border: OutlineInputBorder(),
                      ),
                      items: _parties.map((party) {
                        return DropdownMenuItem(
                          value: party.id,
                          child: Text(party.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPartyId = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Please select a supplier';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount *',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Payment Date
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _paymentDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => _paymentDate = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Payment Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Method
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method *',
                        border: OutlineInputBorder(),
                      ),
                      items: _paymentMethods.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(_formatPaymentMethod(method)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                          if (value == 'cash') {
                            _selectedBankAccountId = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bank Account (only if not cash)
                    if (_paymentMethod != 'cash') ...[
                      DropdownButtonFormField<int>(
                        value: _selectedBankAccountId,
                        decoration: const InputDecoration(
                          labelText: 'Bank Account *',
                          border: OutlineInputBorder(),
                        ),
                        items: _bankAccounts.map((account) {
                          return DropdownMenuItem(
                            value: account.id,
                            child: Text(
                              '${account.accountName} - ₹${account.currentBalance.toStringAsFixed(2)}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedBankAccountId = value);
                        },
                        validator: (value) {
                          if (_paymentMethod != 'cash' && value == null) {
                            return 'Please select a bank account';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Reference Number
                    TextFormField(
                      controller: _referenceController,
                      decoration: const InputDecoration(
                        labelText: 'Reference Number',
                        border: OutlineInputBorder(),
                        hintText: 'Transaction ID, Cheque No, etc.',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        hintText: 'Additional notes...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _paymentMethod == 'cash'
                                  ? 'Amount will be deducted from Cash in Hand'
                                  : 'Amount will be deducted from selected bank account',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'cheque':
        return 'Cheque';
      case 'card':
        return 'Card';
      case 'upi':
        return 'UPI';
      case 'other':
        return 'Other';
      default:
        return method;
    }
  }
}
