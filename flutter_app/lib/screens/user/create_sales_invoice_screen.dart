import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CreateSalesInvoiceScreen extends StatefulWidget {
  const CreateSalesInvoiceScreen({super.key});

  @override
  State<CreateSalesInvoiceScreen> createState() =>
      _CreateSalesInvoiceScreenState();
}

class _CreateSalesInvoiceScreenState extends State<CreateSalesInvoiceScreen> {
  final TextEditingController _invoicePrefixController =
      TextEditingController(text: 'SHI');
  final TextEditingController _invoiceNumberController =
      TextEditingController(text: '101');
  final TextEditingController _paymentTermsController =
      TextEditingController(text: '30');
  final TextEditingController _amountReceivedController =
      TextEditingController(text: '0');

  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _showBankDetails = true;
  bool _autoRoundOff = false;
  bool _markAsFullyPaid = false;
  String _paymentMode = 'Cash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Sales Invoice',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Save & New'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side - Main Form
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bill To Section
                    _buildBillToSection(),
                    const SizedBox(height: 24),

                    // Items Table
                    _buildItemsTable(),
                    const SizedBox(height: 24),

                    // Notes and Terms
                    _buildNotesSection(),
                    const SizedBox(height: 24),

                    // Bank Details
                    if (_showBankDetails) _buildBankDetails(),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Side - Invoice Details
              SizedBox(
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInvoiceDetailsCard(),
                    const SizedBox(height: 16),
                    _buildTotalsCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillToSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill To',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              // Show party selection dialog
            },
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.blue, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '+ Add Party',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40, child: Text('NO')),
                const Expanded(flex: 3, child: Text('ITEMS/ SERVICES')),
                const Expanded(child: Text('HSN/ SAC')),
                const Expanded(child: Text('ITEM CODE')),
                const Expanded(child: Text('MRP')),
                const Expanded(child: Text('QTY')),
                const Expanded(child: Text('PRICE/ITEM (₹)')),
                const Expanded(child: Text('DISCOUNT')),
                const Expanded(child: Text('TAX')),
                const Expanded(child: Text('AMOUNT (₹)')),
                const SizedBox(width: 40),
              ],
            ),
          ),
          // Add Item Row
          InkWell(
            onTap: () {
              // Show add item dialog
            },
            child: Container(
              padding: const EdgeInsets.all(40),
              child: const Center(
                child: Text(
                  '+ Add Item',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          // Subtotal Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('SUBTOTAL'),
                const SizedBox(width: 100),
                const Text('₹0'),
                const SizedBox(width: 50),
                const Text('₹0'),
                const SizedBox(width: 50),
                const Text('₹0'),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Notes'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Terms and Conditions',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Goods once sold will not be taken back or exchanged',
                style: TextStyle(fontSize: 13),
              ),
              const Text(
                '2. All disputes are subject to SURAT jurisdiction only',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bank Details',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Account Number:', '954000210000656'),
          _buildDetailRow('IFSC Code:', 'PUNB0954000'),
          _buildDetailRow(
              'Bank & Branch Name:', 'Punjab National Bank ,PANDESARA'),
          _buildDetailRow('Account Holder\'s Name:', 'SHIVOHAM INTERPRICE'),
          _buildDetailRow('UPI ID:', 'thecompletesoRech-3@okhdfc bank'),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Change Bank Account'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => _showBankDetails = false);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove Bank Account'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invoice Prefix',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _invoicePrefixController,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invoice Number',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _invoiceNumberController,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sales Invoice Date',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _invoiceDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _invoiceDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${_invoiceDate.day} ${_getMonthName(_invoiceDate.month)} ${_invoiceDate.year}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Terms',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _paymentTermsController,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('days'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Due Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _dueDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _dueDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '${_dueDate.day} ${_getMonthName(_dueDate.month)} ${_dueDate.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code_scanner, size: 40),
                const SizedBox(width: 12),
                const Text('Scan Barcode'),
              ],
            ),
            const Divider(height: 32),
            _buildTotalRow('SUBTOTAL', '₹0'),
            _buildTotalRow('', '₹0'),
            _buildTotalRow('', '₹0'),
            const Divider(height: 24),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Discount'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Additional Charges'),
            ),
            const Divider(height: 24),
            _buildTotalRow('Taxable Amount', '₹0'),
            Row(
              children: [
                Checkbox(
                  value: _autoRoundOff,
                  onChanged: (value) {
                    setState(() => _autoRoundOff = value ?? false);
                  },
                ),
                const Text('Auto Round Off'),
                const Spacer(),
                DropdownButton<String>(
                  value: '₹',
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: '₹', child: Text('₹')),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(width: 8),
                const Text('0'),
              ],
            ),
            const Divider(height: 24),
            _buildTotalRow(
              'Total Amount',
              '',
              isBold: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountReceivedController,
              decoration: const InputDecoration(
                labelText: 'Enter Payment amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _paymentMode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'Card', child: Text('Card')),
                      DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _paymentMode = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _markAsFullyPaid,
                  onChanged: (value) {
                    setState(() => _markAsFullyPaid = value ?? false);
                  },
                ),
                const Expanded(
                  child: Text(
                    'Mark as fully paid',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildTotalRow('Amount Received', '₹0'),
            const SizedBox(height: 8),
            _buildTotalRow(
              'Balance Amount',
              '₹0',
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Authorized signatory for Shivoham Interprice',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
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

  @override
  void dispose() {
    _invoicePrefixController.dispose();
    _invoiceNumberController.dispose();
    _paymentTermsController.dispose();
    _amountReceivedController.dispose();
    super.dispose();
  }
}
