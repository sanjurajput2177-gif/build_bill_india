import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/pdf_service.dart';
import '../services/ad_service.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    // Group payments by client name
    final Map<String, List<Payment>> clientPayments = {};
    for (var payment in appState.payments) {
      clientPayments.putIfAbsent(payment.clientName, () => []).add(payment);
    }

    // Filter clients based on search query
    final filteredClientNames = clientPayments.keys.where((name) => 
      name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Client Payments', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const CustomBannerAd(),
          Expanded(
            child: filteredClientNames.isEmpty && _searchQuery.isEmpty && appState.payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.creditCard, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No payment records yet', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredClientNames.length,
                  itemBuilder: (context, index) {
                    final clientName = filteredClientNames[index];
                    final payments = clientPayments[clientName]!;
                    return _ClientPaymentGroupCard(
                      clientName: clientName, 
                      payments: payments
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPaymentForm(context),
        label: const Text('Add Payment'),
        icon: const Icon(LucideIcons.plus),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search client...',
          prefixIcon: const Icon(LucideIcons.search, size: 20),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  void _showPaymentForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const _PaymentForm(),
    );
  }
}

class _ClientPaymentGroupCard extends StatefulWidget {
  final String clientName;
  final List<Payment> payments;

  const _ClientPaymentGroupCard({
    required this.clientName,
    required this.payments,
  });

  @override
  State<_ClientPaymentGroupCard> createState() => _ClientPaymentGroupCardState();
}

class _ClientPaymentGroupCardState extends State<_ClientPaymentGroupCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final totalReceived = widget.payments.fold(0.0, (sum, p) => sum + p.amount);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            title: Text(widget.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text('Total Paid: ₹${totalReceived.toStringAsFixed(0)}', 
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
            trailing: Icon(_isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.payments.length,
              itemBuilder: (context, index) {
                final payment = widget.payments[index];
                return _PaymentItemTile(payment: payment);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        InterstitialAdManager.instance.showAdWithLoading(
                          context,
                          onComplete: () => _generateClientStatement(context),
                        );
                      },
                      icon: const Icon(LucideIcons.fileText, size: 16),
                      label: const Text('Download Statement'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generateClientStatement(BuildContext context) async {
    final appState = context.read<AppState>();
    final profile = appState.companyProfile;
    
    final pdf = await PdfService.generateStatementDocument(
      clientName: widget.clientName,
      payments: widget.payments,
      profile: profile,
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes, 
      filename: 'Statement_${widget.clientName.replaceAll(' ', '_')}.pdf'
    );
  }
}

class _PaymentItemTile extends StatelessWidget {
  final Payment payment;
  const _PaymentItemTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: ListTile(
        dense: true,
        title: Text('₹${payment.amount.toStringAsFixed(0)} via ${payment.mode}'),
        subtitle: Text(DateFormat('dd MMM yyyy').format(payment.date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.share2, size: 16, color: Colors.blue),
              onPressed: () {
                InterstitialAdManager.instance.showAdWithLoading(
                  context,
                  onComplete: () => _shareSingleReceipt(context, payment),
                );
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.edit3, size: 16, color: Colors.grey),
              onPressed: () => _showEditForm(context),
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _PaymentForm(payment: payment),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AppState>().deletePayment(payment.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _shareSingleReceipt(BuildContext context, Payment payment) async {
    final appState = context.read<AppState>();
    final profile = appState.companyProfile;
    
    final pdf = await PdfService.generateReceiptDocument(
      payment: payment,
      profile: profile,
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes, 
      filename: 'Receipt_${payment.clientName.replaceAll(' ', '_')}.pdf'
    );
  }
}

class _PaymentForm extends StatefulWidget {
  final Payment? payment;
  const _PaymentForm({this.payment});

  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  late TextEditingController _clientController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _mode;

  @override
  void initState() {
    super.initState();
    _clientController = TextEditingController(text: widget.payment?.clientName ?? '');
    _amountController = TextEditingController(text: widget.payment?.amount.toStringAsFixed(0) ?? '');
    _selectedDate = widget.payment?.date ?? DateTime.now();
    _mode = widget.payment?.mode ?? 'Cash';
  }

  @override
  void dispose() {
    _clientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.payment == null ? 'Record Payment' : 'Edit Payment', 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _clientController.text),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return appState.clients
                  .map((c) => c.name)
                  .where((name) => name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (String selection) {
              _clientController.text = selection;
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              // Sync the local controller with autocomplete controller if needed
              // or just use the provided controller.
              // To keep it simple and truly "editable", we can just use a normal TextField
              // but Autocomplete is better.
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Client Name',
                  prefixIcon: Icon(LucideIcons.user),
                  hintText: 'Type or select client',
                ),
                onChanged: (val) => _clientController.text = val,
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (Rs)', prefixIcon: Icon(LucideIcons.indianRupee)),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.calendar),
            title: Text('Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
            trailing: TextButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: const Text('Change'),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _mode,
            decoration: const InputDecoration(labelText: 'Payment Mode', prefixIcon: Icon(LucideIcons.creditCard)),
            items: ['Cash', 'Cheque', 'Online/UPI'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) => setState(() => _mode = val!),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], foregroundColor: Colors.white),
              onPressed: _save,
              child: Text(widget.payment == null ? 'Save Payment' : 'Update Payment'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _save() {
    if (_clientController.text.isEmpty || _amountController.text.isEmpty) return;
    _performSave();
  }

  void _performSave() {
    final payment = Payment(
      id: widget.payment?.id ?? const Uuid().v4(),
      invoiceId: 'MANUAL',
      clientName: _clientController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      date: _selectedDate,
      mode: _mode,
    );

    if (widget.payment == null) {
      context.read<AppState>().addPayment(payment);
    } else {
      context.read<AppState>().updatePayment(payment);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.payment == null ? 'Payment recorded!' : 'Payment updated!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
