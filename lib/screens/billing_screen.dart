import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/ad_service.dart';

class BillingScreen extends StatefulWidget {
  final Invoice? editInvoice;
  const BillingScreen({super.key, this.editInvoice});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientAddressController = TextEditingController();
  List<BillItem> _items = [];
  bool _gstEnabled = true;
  double _gstPercentage = 18;
  String? _editingInvoiceId;

  void _resetForm() {
    _clientNameController.clear();
    _clientPhoneController.clear();
    _clientEmailController.clear();
    _clientAddressController.clear();
    _items = [];
    _editingInvoiceId = null;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.editInvoice != null) {
      _editingInvoiceId = widget.editInvoice!.id;
      _clientNameController.text = widget.editInvoice!.clientName;
      _clientPhoneController.text = widget.editInvoice!.clientPhone;
      _clientEmailController.text = widget.editInvoice!.clientEmail ?? '';
      _clientAddressController.text = widget.editInvoice!.clientAddress ?? '';
      _items = List.from(widget.editInvoice!.items);
      _gstEnabled = widget.editInvoice!.gstAmount > 0;
      _gstPercentage = widget.editInvoice!.gstPercentage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingInvoiceId != null ? 'Edit Invoice' : 'New Invoice', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCcw),
            tooltip: 'New Bill',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Start New Bill?'),
                  content: const Text('This will clear all current items and client details.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetForm();
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientSelection(appState),
            const SizedBox(height: 16),
            _buildClientInfo(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Invoice Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildItemsList(),
            const SizedBox(height: 24),
            _buildGstToggle(),
            const SizedBox(height: 16),
            _buildTotals(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSelection(AppState appState) {
    if (appState.clients.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: const Text('Select Existing Client', style: TextStyle(fontSize: 14)),
        leading: const Icon(LucideIcons.users, size: 18),
        children: appState.clients.map((client) => ListTile(
          title: Text(client.name),
          subtitle: Text(client.phone),
          onTap: () {
            setState(() {
              _clientNameController.text = client.name;
              _clientPhoneController.text = client.phone;
              _clientEmailController.text = client.email ?? '';
              _clientAddressController.text = client.address ?? '';
            });
          },
        )).toList(),
      ),
    );
  }

  Widget _buildClientInfo() {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _clientNameController,
              decoration: const InputDecoration(
                labelText: 'Client Name',
                prefixIcon: Icon(LucideIcons.user, size: 18),
                hintText: 'Enter name or select above',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clientPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(LucideIcons.phone, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clientEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(LucideIcons.mail, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clientAddressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(LucideIcons.mapPin, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        ),
        child: const Column(
          children: [
            Icon(LucideIcons.package, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No items added yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            '${item.quantity} x ${item.totalUnits.toStringAsFixed(2)} ${_getUnitLabel(item.type)} @ ₹${item.rate}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          onTap: () => _showAddItemDialog(editItem: item, index: index),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${item.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                onPressed: () => setState(() => _items.removeAt(index)),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getUnitLabel(String type) {
    switch (type) {
      case 'volume': return 'Cu.Ft';
      case 'area': return 'Sq.Ft';
      case 'sqyard': return 'Sq.Yd';
      default: return 'Units';
    }
  }

  Widget _buildGstToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Apply GST (18%)', style: TextStyle(fontWeight: FontWeight.w500)),
        Switch(
          value: _gstEnabled,
          onChanged: (val) => setState(() => _gstEnabled = val),
          activeThumbColor: Colors.blue[600],
        ),
      ],
    );
  }

  Widget _buildTotals() {
    double subtotal = _items.fold(0.0, (sum, item) => sum + item.subtotal);
    double gst = _gstEnabled ? (subtotal * _gstPercentage / 100) : 0;
    double total = subtotal + gst;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              _totalRow('Subtotal', subtotal, color: Colors.grey[700]),
              if (_gstEnabled) _totalRow('GST (18%)', gst, color: Colors.grey[700]),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              _totalRow('Grand Total', total, isBold: true, color: Colors.blue[800], fontSize: 20),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _items.isEmpty ? null : _saveInvoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.save),
                SizedBox(width: 8),
                Text('Save Invoice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _totalRow(String label, double amount, {bool isBold = false, Color? color, double fontSize = 16}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color, fontSize: fontSize)),
        Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color, fontSize: fontSize)),
      ],
    );
  }

  void _showAddItemDialog({BillItem? editItem, int? index}) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(editItem: editItem),
    ).then((newItem) {
      if (newItem != null && newItem is BillItem) {
        setState(() {
          if (index != null) {
            _items[index] = newItem;
          } else {
            _items.add(newItem);
          }
        });
      }
    });
  }

  void _saveInvoice() async {
    if (_items.isEmpty) return;

    InterstitialAdManager.instance.showAdWithLoading(context, onComplete: () async {
      final String clientName = _clientNameController.text.trim().isEmpty ? 'Walk-in Client' : _clientNameController.text.trim();
      final String clientPhone = _clientPhoneController.text.trim();
      final String clientEmail = _clientEmailController.text.trim();
      final String clientAddress = _clientAddressController.text.trim();
      
      final double subtotal = _items.fold(0.0, (sum, item) => sum + item.subtotal);
      final double gstAmount = _gstEnabled ? (subtotal * _gstPercentage / 100) : 0.0;
      final double totalAmount = subtotal + gstAmount;

      final invoice = Invoice(
        id: _editingInvoiceId ?? 'INV-${DateTime.now().millisecondsSinceEpoch}',
        clientName: clientName,
        clientPhone: clientPhone,
        clientEmail: clientEmail.isEmpty ? null : clientEmail,
        clientAddress: clientAddress.isEmpty ? null : clientAddress,
        date: widget.editInvoice?.date ?? DateTime.now(),
        items: List.from(_items),
        gstPercentage: _gstEnabled ? _gstPercentage : 0,
        subtotal: subtotal,
        gstAmount: gstAmount,
        totalAmount: totalAmount,
        payments: widget.editInvoice?.payments ?? [],
        balance: totalAmount - (widget.editInvoice?.payments.fold(0.0, (sum, p) => (sum ?? 0.0) + p.amount) ?? 0.0),
      );

      // Save invoice to History
      final appState = context.read<AppState>();
      await appState.saveInvoice(invoice);

      if (!mounted) return;

      // Navigate to History Screen
      appState.updateSelectedIndex(2); // Navigate to History tab
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice saved to history.')),
      );
      _resetForm();
    });
  }
}

class AddItemDialog extends StatefulWidget {
  final BillItem? editItem;
  const AddItemDialog({super.key, this.editItem});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _descController = TextEditingController();
  final _rateController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  
  final _lFtController = TextEditingController();
  final _lInController = TextEditingController();
  final _wFtController = TextEditingController();
  final _wInController = TextEditingController();
  final _hFtController = TextEditingController();
  final _hInController = TextEditingController();

  String _type = 'volume'; // 'volume', 'area', 'sqyard', 'unit'

  @override
  void initState() {
    super.initState();
    if (widget.editItem != null) {
      final item = widget.editItem!;
      _descController.text = item.description;
      _rateController.text = item.rate.toString();
      _qtyController.text = item.quantity.toString();
      _type = item.type;
      
      _lFtController.text = item.length.ft.toString();
      _lInController.text = item.length.inch.toString();
      _wFtController.text = item.width.ft.toString();
      _wInController.text = item.width.inch.toString();
      if (item.height != null) {
        _hFtController.text = item.height!.ft.toString();
        _hInController.text = item.height!.inch.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editItem != null ? 'Edit Item' : 'Add New Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description (e.g. Concrete, Tiles)'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Calculation Type'),
              items: const [
                DropdownMenuItem(value: 'volume', child: Text('Volume (Cu.Ft)')),
                DropdownMenuItem(value: 'area', child: Text('Area (Sq.Ft)')),
                DropdownMenuItem(value: 'sqyard', child: Text('Area (Sq.Yards)')),
                DropdownMenuItem(value: 'unit', child: Text('Per Unit / Running Ft')),
              ],
              onChanged: (val) => setState(() => _type = val!),
            ),
            const SizedBox(height: 16),
            if (_type != 'unit') ...[
              _buildDimensionInput('Length', _lFtController, _lInController),
              _buildDimensionInput('Width', _wFtController, _wInController),
              if (_type == 'volume')
                _buildDimensionInput('Height/Depth', _hFtController, _hInController),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Rate (Rs)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _onAdd,
          child: Text(widget.editItem != null ? 'Update Item' : 'Add Item'),
        ),
      ],
    );
  }

  Widget _buildDimensionInput(String label, TextEditingController ft, TextEditingController inch) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            child: TextField(
              controller: ft,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Ft', isDense: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: inch,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'In', isDense: true),
            ),
          ),
        ],
      ),
    );
  }

  void _onAdd() {
    if (_descController.text.isEmpty || _rateController.text.isEmpty) return;

    int lFt = int.tryParse(_lFtController.text) ?? 0;
    int lIn = int.tryParse(_lInController.text) ?? 0;
    int wFt = int.tryParse(_wFtController.text) ?? 0;
    int wIn = int.tryParse(_wInController.text) ?? 0;
    int hFt = int.tryParse(_hFtController.text) ?? 0;
    int hIn = int.tryParse(_hInController.text) ?? 0;

    double length = lFt + (lIn / 12.0);
    double width = wFt + (wIn / 12.0);
    double height = hFt + (hIn / 12.0);
    
    double totalUnits = 1.0;
    if (_type == 'volume') {
      totalUnits = length * width * height;
    } else if (_type == 'area') {
      totalUnits = length * width;
    } else if (_type == 'sqyard') {
      totalUnits = (length * width) / 9.0;
    }

    int qty = int.tryParse(_qtyController.text) ?? 1;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double subtotal = totalUnits * qty * rate;

    final item = BillItem(
      id: const Uuid().v4(),
      description: _descController.text,
      type: _type,
      length: Dimension(ft: lFt, inch: lIn),
      width: Dimension(ft: wFt, inch: wIn),
      height: _type == 'volume' ? Dimension(ft: hFt, inch: hIn) : null,
      quantity: qty,
      rate: rate,
      totalUnits: totalUnits,
      subtotal: subtotal,
    );

    Navigator.pop(context, item);
  }
}
