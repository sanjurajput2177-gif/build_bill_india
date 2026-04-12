import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import 'billing_screen.dart';
import 'pdf_preview_screen.dart';
import '../services/pdf_service.dart';
import '../services/ad_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Preload ad when history screen is opened
    InterstitialAdManager.instance.loadAd();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final invoices = appState.invoices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: invoices.isEmpty
          ? const Center(child: Text('No invoices found'))
          : ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final inv = invoices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.blue[100], child: const Icon(LucideIcons.fileText, size: 20)),
                    title: Text(inv.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(inv.date)),
                    trailing: Text('Rs. ${inv.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                    onTap: () => _showInvoiceOptions(context, inv, appState.companyProfile),
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBannerAd(),
    );
  }

  void _showInvoiceOptions(BuildContext context, Invoice invoice, CompanyProfile profile) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.edit, color: Colors.blue),
              title: const Text('Edit Invoice'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BillingScreen(editInvoice: invoice),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.fileText, color: Colors.purple),
              title: const Text('Preview Invoice'),
              onTap: () {
                Navigator.pop(context);
                InterstitialAdManager.instance.showAdWithLoading(
                  context,
                  onComplete: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfPreviewScreen(
                          invoice: invoice,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.share2, color: Colors.green),
              title: const Text('Share Invoice'),
              onTap: () {
                Navigator.pop(context);
                
                // Trigger the Interstitial Ad before sharing
                InterstitialAdManager.instance.showAdWithLoading(
                  context,
                  onComplete: () {
                    // Execute share logic once
                    PdfService.shareInvoicePdf(
                      invoice: invoice,
                      profile: profile,
                    );
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: Colors.red),
              title: const Text('Delete Invoice', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, invoice.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: const Text('Are you sure you want to permanently delete this invoice?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteInvoice(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
