import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/pdf_service.dart';
import '../services/app_state.dart';
import '../services/ad_service.dart';

class PdfPreviewScreen extends StatefulWidget {
  final Invoice invoice;

  const PdfPreviewScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _generateInitialPdf();
  }

  Future<void> _generateInitialPdf() async {
    final profile = context.read<AppState>().companyProfile;
    final bytes = await PdfService.getInvoicePdfBytes(
      invoice: widget.invoice,
      profile: profile,
    );
    if (mounted) {
      setState(() {
        _pdfBytes = bytes;
      });
    }
  }

  Future<void> _sharePdf(BuildContext context, CompanyProfile profile) async {
    try {
      final bytes = _pdfBytes ?? await PdfService.getInvoicePdfBytes(
        invoice: widget.invoice,
        profile: profile,
      );

      final tempDir = await getTemporaryDirectory();
      final fileName = 'Measurement_Sheet_${widget.invoice.clientName.replaceAll(' ', '_')}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Measurement Sheet - ${widget.invoice.clientName}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.read<AppState>().companyProfile;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share PDF',
            onPressed: () {
              InterstitialAdManager.instance.showAdWithLoading(
                context,
                onComplete: () {
                  _sharePdf(context, profile);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print PDF',
            onPressed: () {
              InterstitialAdManager.instance.showAdWithLoading(
                context,
                onComplete: () async {
                  final bytes = _pdfBytes ?? await PdfService.getInvoicePdfBytes(
                    invoice: widget.invoice,
                    profile: profile,
                  );
                  await Printing.layoutPdf(onLayout: (_) => bytes);
                },
              );
            },
          ),
        ],
      ),
      body: _pdfBytes == null
          ? const Center(child: CircularProgressIndicator())
          : PdfPreview(
              build: (format) => _pdfBytes!,
              allowPrinting: false,
              allowSharing: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
            ),
    );
  }
}
