import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/payment_in_service.dart';
import '../../services/party_service.dart';
import '../../models/party_model.dart';
import '../../providers/organization_provider.dart';
import '../../widgets/dialog_scaffold.dart';

class CreatePaymentInScreen extends StatefulWidget {
  final int? paymentId;
  final Map<String, dynamic>? paymentData;

  const CreatePaymentInScreen({
    super.key,
    this.paymentId,
    this.paymentData,
  });

  @override
  State<CreatePaymentInScreen> createState() => _CreatePaymentInScreenState();
}

class _CreatePaymentInScreenState extends State<CreatePaymentInScreen> {
  final PaymentInService _paymentService = PaymentInService();
  final PartyService _partyService = PartyService();
  final TextEditingController _paymentNumberController =
      TextEditingController(text: '83');
  final TextEditingController _amountController =
      TextEditingController(text: '0');
  final TextEditingController _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  String _paymentMode = 'Cash';
  int? _selectedPartyId;
  String? _selectedPartyName;
  int? _selectedBankAccountId;
  String? _selectedBankAccountName;
  bool _isSaving = false;
  List<PartyModel> _parties = [];
  List<dynamic> _bankAccounts = [];

  bool get _isEditMode =>
      widget.paymentId != null || widget.paymentData != null;

  @override
  void initState() {
    super.initState();
    _loadNextPaymentNumber();
  }

  Future<void> _loadNextPaymentNumber() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization != null) {
      try {
        final result = await _paymentService
            .getNextPaymentNumber(orgProvider.selectedOrganization!.id);
        setState(() {
          _paymentNumberController.text = result['next_number'].toString();

          // Load existing payment data if in edit mode
          if (widget.paymentData != null) {
            debugPrint('🔄 Loading payment data: ${widget.paymentData}');
            _paymentNumberController.text =
                widget.paymentData!['payment_number'] ??
                    _paymentNumberController.text;
            _selectedPartyId = widget.paymentData!['party_id'];
            _selectedPartyName = widget.paymentData!['party_name'];
            _amountController.text =
                widget.paymentData!['amount']?.toString() ?? '';
            // Normalize payment mode to match dropdown values
            final mode = widget.paymentData!['payment_mode'] ?? 'cash';
            _paymentMode =
                mode[0].toUpperCase() + mode.substring(1).toLowerCase();
            _notesController.text = widget.paymentData!['notes'] ?? '';
            if (widget.paymentData!['payment_date'] != null) {
              _paymentDate =
                  DateTime.parse(widget.paymentData!['payment_date']);
            }
            debugPrint(
                '✅ Loaded party: ID=$_selectedPartyId, Name=$_selectedPartyName');
          }
        });
      } catch (e) {
        debugPrint('Error loading next payment number: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: _isEditMode ? 'Edit Payment In' : 'Record Payment In',
      onSave: _savePayment,
      onSettings: () {
        Navigator.pushNamed(context, '/settings');
      },
      isSaving: _isSaving,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Party Name
                    const Text(
                      'Party Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showPartySelectionDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedPartyName ??
                                    'Search party by name or number',
                                style: TextStyle(
                                  color: _selectedPartyName == null
                                      ? Colors.grey[600]
                                      : Colors.black,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Enter Payment Amount
                    const Text(
                      'Enter Payment Amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Empty State
                    Container(
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Transactions yet!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select Party Name to view transactions',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _showPartySelectionDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Select Party'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Side
              SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Date
                    const Text(
                      'Payment Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _paymentDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _paymentDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${_paymentDate.day} ${_getMonthName(_paymentDate.month)} ${_paymentDate.year}',
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Mode
                    const Text(
                      'Payment Mode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _paymentMode,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'Card', child: Text('Card')),
                        DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                        DropdownMenuItem(
                            value: 'Bank Transfer',
                            child: Text('Bank Transfer')),
                        DropdownMenuItem(
                            value: 'Cheque', child: Text('Cheque')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _paymentMode = value;
                            // Reset bank account selection when switching to/from cash
                            if (value == 'Cash') {
                              _selectedBankAccountId = null;
                              _selectedBankAccountName = null;
                            } else {
                              _loadBankAccounts();
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bank Account Selection (only show for non-cash payments)
                    if (_paymentMode != 'Cash') ...[
                      const Text(
                        'Bank Account',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _bankAccounts.isEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Loading bank accounts...',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : DropdownButtonFormField<int>(
                              value: _selectedBankAccountId,
                              decoration: InputDecoration(
                                hintText: 'Select bank account',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              items: _bankAccounts
                                  .map((account) => DropdownMenuItem<int>(
                                        value: account['id'],
                                        child: Text(
                                          '${account['account_name']} - ₹${NumberFormat('#,##,###.##').format(double.parse(account['current_balance'].toString()))}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  final account = _bankAccounts.firstWhere(
                                    (acc) => acc['id'] == value,
                                  );
                                  setState(() {
                                    _selectedBankAccountId = value;
                                    _selectedBankAccountName =
                                        account['account_name'];
                                  });
                                }
                              },
                            ),
                      const SizedBox(height: 16),
                    ],

                    // Payment In Number
                    const Text(
                      'Payment In Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _paymentNumberController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter Notes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Future<void> _showPartySelectionDialog() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an organization first')),
        );
      }
      return;
    }

    try {
      _parties =
          await _partyService.getParties(orgProvider.selectedOrganization!.id);

      if (!mounted) return;

      final selectedParty = await showDialog<PartyModel>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Party',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search party by name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // TODO: Implement search filtering
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                Expanded(
                  child: _parties.isEmpty
                      ? const Center(
                          child: Text('No parties found'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _parties.length,
                          itemBuilder: (context, index) {
                            final party = _parties[index];
                            return ListTile(
                              title: Text(party.name),
                              subtitle: Text(party.phone),
                              trailing: party.partyType == 'customer'
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Customer',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : null,
                              onTap: () => Navigator.pop(context, party),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );

      if (selectedParty != null) {
        setState(() {
          _selectedPartyId = selectedParty.id;
          _selectedPartyName = selectedParty.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading parties: $e')),
        );
      }
    }
  }

  Future<void> _loadBankAccounts() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    try {
      final response = await _paymentService
          .getBankAccounts(orgProvider.selectedOrganization!.id);
      setState(() {
        _bankAccounts = response;
      });
    } catch (e) {
      // Silently fail - user can still proceed without selecting bank account
      print('Error loading bank accounts: $e');
    }
  }

  Future<void> _savePayment() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an organization first')),
        );
      }
      return;
    }

    // Validate inputs
    if (_selectedPartyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a party')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Validate bank account for non-cash payments
    if (_paymentMode != 'Cash' && _selectedBankAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank account')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final paymentData = {
        'organization_id': orgProvider.selectedOrganization!.id,
        'party_id': _selectedPartyId,
        'payment_number': _paymentNumberController.text,
        'payment_date': _paymentDate.toIso8601String().split('T')[0],
        'amount': amount,
        'payment_mode': _paymentMode,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        if (_selectedBankAccountId != null)
          'bank_account_id': _selectedBankAccountId,
      };

      if (_isEditMode && widget.paymentId != null) {
        // Update existing payment
        await _paymentService.updatePaymentIn(widget.paymentId!, paymentData);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment updated successfully')),
          );
        }
      } else {
        // Create new payment
        await _paymentService.createPayment(paymentData);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Payment saved and account balance updated successfully')),
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
  void dispose() {
    _paymentNumberController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
