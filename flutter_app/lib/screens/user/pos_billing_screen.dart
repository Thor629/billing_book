import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/item_model.dart';
import '../../providers/organization_provider.dart';
import '../../services/pos_service.dart';

class PosBillingScreen extends StatefulWidget {
  const PosBillingScreen({super.key});

  @override
  State<PosBillingScreen> createState() => _PosBillingScreenState();
}

class _PosBillingScreenState extends State<PosBillingScreen> {
  final PosService _posService = PosService();
  final List<BillingScreenData> _billingScreens = [
    BillingScreenData(screenNumber: 1)
  ];
  int _currentScreenIndex = 0;
  final int _maxScreens = 5;

  BillingScreenData get _currentScreen => _billingScreens[_currentScreenIndex];

  void _holdBillAndCreateNew() {
    if (_billingScreens.length >= _maxScreens) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $_maxScreens billing screens allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      final newScreenNumber = _billingScreens.length + 1;
      _billingScreens.add(BillingScreenData(screenNumber: newScreenNumber));
      _currentScreenIndex = _billingScreens.length - 1;
    });
  }

  void _closeScreen(int index) {
    if (_billingScreens.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot close the last billing screen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _billingScreens.removeAt(index);
      if (_currentScreenIndex >= _billingScreens.length) {
        _currentScreenIndex = _billingScreens.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('POS Billing'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.help_outline),
            label: const Text('Watch how to use POS Billing'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Settings'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Scrollable Tab Bar
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _billingScreens.length,
              itemBuilder: (context, index) {
                final screen = _billingScreens[index];
                final isActive = index == _currentScreenIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentScreenIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      border: Border(
                        right: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Billing Screen ${screen.screenNumber}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black87,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (_billingScreens.length > 1) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _closeScreen(index),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: isActive ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Billing Screen Content
          Expanded(
            child: BillingScreenWidget(
              key: ValueKey(_currentScreen.screenNumber),
              screenData: _currentScreen,
              posService: _posService,
              onHoldBill: _holdBillAndCreateNew,
            ),
          ),
        ],
      ),
    );
  }
}

// Data class to hold billing screen state
class BillingScreenData {
  final int screenNumber;
  final List<BillingItem> billingItems = [];
  final TextEditingController searchController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController additionalChargeController =
      TextEditingController();
  final TextEditingController receivedAmountController =
      TextEditingController();
  List<ItemModel> searchResults = [];
  bool isSearching = false;
  bool isSaving = false;
  String paymentMethod = 'Cash';
  bool isCashSale = true;

  BillingScreenData({required this.screenNumber});

  void dispose() {
    searchController.dispose();
    discountController.dispose();
    additionalChargeController.dispose();
    receivedAmountController.dispose();
  }
}

// Widget for individual billing screen
class BillingScreenWidget extends StatefulWidget {
  final BillingScreenData screenData;
  final PosService posService;
  final VoidCallback onHoldBill;

  const BillingScreenWidget({
    super.key,
    required this.screenData,
    required this.posService,
    required this.onHoldBill,
  });

  @override
  State<BillingScreenWidget> createState() => _BillingScreenWidgetState();
}

class _BillingScreenWidgetState extends State<BillingScreenWidget> {
  double get _subTotal {
    return widget.screenData.billingItems
        .fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  double get _discount {
    return double.tryParse(widget.screenData.discountController.text) ?? 0.0;
  }

  double get _additionalCharge {
    return double.tryParse(widget.screenData.additionalChargeController.text) ??
        0.0;
  }

  double get _tax {
    return widget.screenData.billingItems
        .fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  double get _totalAmount {
    return _subTotal - _discount + _additionalCharge;
  }

  double get _receivedAmount {
    return double.tryParse(widget.screenData.receivedAmountController.text) ??
        0.0;
  }

  double get _changeAmount {
    return _receivedAmount - _totalAmount;
  }

  Future<void> _searchItems(String query) async {
    if (query.isEmpty) {
      setState(() {
        widget.screenData.searchResults = [];
      });
      return;
    }

    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    if (orgProvider.selectedOrganization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an organization first')),
      );
      return;
    }

    setState(() {
      widget.screenData.isSearching = true;
    });

    try {
      final results = await widget.posService.searchItems(
        orgProvider.selectedOrganization!.id,
        query,
      );
      setState(() {
        widget.screenData.searchResults = results;
        widget.screenData.isSearching = false;
      });
    } catch (e) {
      setState(() {
        widget.screenData.isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching items: $e')),
        );
      }
    }
  }

  void _addItemFromSearch(ItemModel item) {
    final existingIndex = widget.screenData.billingItems.indexWhere(
      (billingItem) => billingItem.itemId == item.id,
    );

    setState(() {
      if (existingIndex >= 0) {
        widget.screenData.billingItems[existingIndex].quantity++;
      } else {
        widget.screenData.billingItems.add(
          BillingItem(
            itemId: item.id,
            itemName: item.itemName,
            itemCode: item.itemCode,
            mrp: item.mrp,
            sellingPrice: item.sellingPrice,
            quantity: 1,
            taxRate: item.gstRate,
          ),
        );
      }
      widget.screenData.searchController.clear();
      widget.screenData.searchResults = [];
    });
  }

  void _removeItem(int index) {
    setState(() {
      widget.screenData.billingItems.removeAt(index);
    });
  }

  void _changeQuantity(int index, int delta) {
    setState(() {
      final newQty = widget.screenData.billingItems[index].quantity + delta;
      if (newQty > 0) {
        widget.screenData.billingItems[index].quantity = newQty;
      }
    });
  }

  void _changePrice(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(
          text: widget.screenData.billingItems[index].sellingPrice.toString(),
        );
        return AlertDialog(
          title: const Text('Change Price'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'New Price',
              prefixText: '₹ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.screenData.billingItems[index].sellingPrice =
                      double.tryParse(controller.text) ??
                          widget.screenData.billingItems[index].sellingPrice;
                });
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBill({bool print = false}) async {
    if (widget.screenData.billingItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to the bill')),
      );
      return;
    }

    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    if (orgProvider.selectedOrganization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an organization first')),
      );
      return;
    }

    setState(() {
      widget.screenData.isSaving = true;
    });

    try {
      final items = widget.screenData.billingItems.map((item) {
        return {
          'item_id': item.itemId,
          'quantity': item.quantity,
          'selling_price': item.sellingPrice,
          'gst_rate': item.taxRate,
        };
      }).toList();

      final receivedAmount =
          _receivedAmount > 0 ? _receivedAmount : _totalAmount;

      final result = await widget.posService.saveBill(
        organizationId: orgProvider.selectedOrganization!.id,
        items: items,
        discount: _discount,
        additionalCharge: _additionalCharge,
        paymentMethod: widget.screenData.paymentMethod,
        receivedAmount: receivedAmount,
        isCashSale: widget.screenData.isCashSale,
      );

      setState(() {
        widget.screenData.isSaving = false;
      });

      if (print) {
        await _printReceipt(
          invoiceNumber: result['invoice_number'],
          organizationName: orgProvider.selectedOrganization!.name,
          receivedAmount: receivedAmount,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              print
                  ? 'Bill saved and sent to printer! Invoice: ${result['invoice_number']}'
                  : 'Bill saved successfully! Invoice: ${result['invoice_number']}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      _resetBill();
    } catch (e) {
      setState(() {
        widget.screenData.isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bill: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printReceipt({
    required String invoiceNumber,
    required String organizationName,
    required double receivedAmount,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    organizationName,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Invoice: $invoiceNumber'),
                    pw.Text(
                      'Date: ${DateTime.now().toString().substring(0, 16)}',
                    ),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'Item',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'Qty',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'Price',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
                pw.Divider(),
                ...widget.screenData.billingItems.map((item) {
                  return pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              item.itemName,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              '${item.quantity}',
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              '₹${item.sellingPrice.toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              '₹${item.taxableAmount.toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                    ],
                  );
                }),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Sub Total:'),
                    pw.Text('₹${_subTotal.toStringAsFixed(2)}'),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tax:'),
                    pw.Text('₹${_tax.toStringAsFixed(2)}'),
                  ],
                ),
                if (_discount > 0) ...[
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Discount:'),
                      pw.Text('-₹${_discount.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
                if (_additionalCharge > 0) ...[
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Additional Charge:'),
                      pw.Text('₹${_additionalCharge.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Amount:',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '₹${_totalAmount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Payment Method:'),
                    pw.Text(widget.screenData.paymentMethod),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Received Amount:'),
                    pw.Text('₹${receivedAmount.toStringAsFixed(2)}'),
                  ],
                ),
                if (_changeAmount > 0) ...[
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Change to Return:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '₹${_changeAmount.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    'Thank you for your business!',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    'Visit Again',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'POS_Receipt_$invoiceNumber',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing receipt: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _resetBill() {
    setState(() {
      widget.screenData.billingItems.clear();
      widget.screenData.searchController.clear();
      widget.screenData.discountController.clear();
      widget.screenData.additionalChargeController.clear();
      widget.screenData.receivedAmountController.clear();
      widget.screenData.paymentMethod = 'Cash';
      widget.screenData.isCashSale = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Panel - Billing Items
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Billing Screen ${widget.screenData.screenNumber}',
                        style: AppTextStyles.h4,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: widget.onHoldBill,
                        icon: const Icon(Icons.pause_circle_outline),
                        label: const Text('Hold Bill & Create Another'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: widget.screenData.searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Search by Item Name/Item Code or Scan Barcode',
                          prefixIcon: widget.screenData.isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (value) {
                          if (value.length >= 2) {
                            _searchItems(value);
                          } else {
                            setState(() {
                              widget.screenData.searchResults = [];
                            });
                          }
                        },
                      ),
                      if (widget.screenData.searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.screenData.searchResults.length,
                            itemBuilder: (context, index) {
                              final item =
                                  widget.screenData.searchResults[index];
                              return ListTile(
                                dense: true,
                                title: Text(item.itemName),
                                subtitle: Text(
                                  '${item.itemCode} - ₹${item.sellingPrice.toStringAsFixed(2)}',
                                ),
                                trailing: Text(
                                  'Stock: ${item.stockQty}',
                                  style: TextStyle(
                                    color: item.stockQty > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () => _addItemFromSearch(item),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // Items Table
                Expanded(
                  child: widget.screenData.billingItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Add items by searching item name or item code',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Or',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner,
                                    size: 20,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Simply scan barcode to add items',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Table(
                            border: TableBorder.all(color: Colors.grey[200]!),
                            columnWidths: const {
                              0: FixedColumnWidth(50),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(1.5),
                              3: FixedColumnWidth(80),
                              4: FixedColumnWidth(100),
                              5: FixedColumnWidth(100),
                              6: FixedColumnWidth(120),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                ),
                                children: [
                                  _buildTableHeader('NO'),
                                  _buildTableHeader('ITEMS'),
                                  _buildTableHeader('ITEM CODE'),
                                  _buildTableHeader('MRP'),
                                  _buildTableHeader('SP (₹)'),
                                  _buildTableHeader('QUANTITY'),
                                  _buildTableHeader('AMOUNT (₹)'),
                                ],
                              ),
                              ...widget.screenData.billingItems
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                return TableRow(
                                  children: [
                                    _buildTableCell('${index + 1}'),
                                    _buildTableCell(item.itemName),
                                    _buildTableCell(item.itemCode),
                                    _buildTableCell(
                                        '₹${item.mrp.toStringAsFixed(2)}'),
                                    _buildTableCellWithAction(
                                      '₹${item.sellingPrice.toStringAsFixed(2)}',
                                      () => _changePrice(index),
                                    ),
                                    _buildQuantityCell(item.quantity, index),
                                    _buildTableCellWithDelete(
                                      '₹${item.totalAmount.toStringAsFixed(2)}',
                                      () => _removeItem(index),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),

        // Right Panel - Bill Summary
        Container(
          width: 380,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Bill details',
                      style: AppTextStyles.h4,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBillRow(
                          'Sub Total', '₹${_subTotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      _buildBillRow('Tax', '₹${_tax.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: widget.screenData.discountController,
                              decoration: InputDecoration(
                                labelText: 'Add Discount',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller:
                                  widget.screenData.additionalChargeController,
                              decoration: InputDecoration(
                                labelText: 'Add Additional Charge',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '₹ ${_totalAmount.toStringAsFixed(2)}',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller:
                                  widget.screenData.receivedAmountController,
                              decoration: InputDecoration(
                                labelText: 'Received Amount',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.green[50],
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: widget.screenData.paymentMethod,
                            items: ['Cash', 'Card', 'UPI', 'Cheque']
                                .map((method) => DropdownMenuItem(
                                      value: method,
                                      child: Text(method),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                widget.screenData.paymentMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_receivedAmount > 0 && _changeAmount > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Change to Return',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '₹ ${_changeAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Customer Details',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: widget.screenData.isCashSale,
                            onChanged: (value) {
                              setState(() {
                                widget.screenData.isCashSale = value!;
                              });
                            },
                          ),
                          const Text('Cash Sale'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.screenData.isSaving
                            ? null
                            : () => _saveBill(print: true),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                        ),
                        child: widget.screenData.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save & Print'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.screenData.isSaving
                            ? null
                            : () => _saveBill(print: false),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: widget.screenData.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Bill'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCellWithAction(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.primary,
            decoration: TextDecoration.underline,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildQuantityCell(int quantity, int index) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 18),
            onPressed: () => _changeQuantity(index, -1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 18),
            onPressed: () => _changeQuantity(index, 1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCellWithDelete(String text, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class BillingItem {
  final int itemId;
  final String itemName;
  final String itemCode;
  final double mrp;
  double sellingPrice;
  int quantity;
  final double taxRate;

  BillingItem({
    required this.itemId,
    required this.itemName,
    required this.itemCode,
    required this.mrp,
    required this.sellingPrice,
    required this.quantity,
    required this.taxRate,
  });

  double get taxableAmount => sellingPrice * quantity;
  double get taxAmount => (taxableAmount * taxRate) / 100;
  double get totalAmount => taxableAmount + taxAmount;
}
