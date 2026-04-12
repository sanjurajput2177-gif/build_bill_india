import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/app_state.dart';
import '../models/models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings & Info', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _buildSettingTile(
            context,
            icon: LucideIcons.building,
            title: 'Business Profile',
            subtitle: 'Update GST, PAN, and Company Details',
            onTap: () => _showBusinessProfileDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.info,
            title: 'About App',
            onTap: () => _showAboutDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.shieldCheck,
            title: 'Privacy Policy',
            onTap: () => _showPrivacyPolicyDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.fileText,
            title: 'Terms & Conditions',
            onTap: () => _showTermsDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.trash2,
            title: 'Data Deletion Policy',
            onTap: () => _showDataDeletionDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.helpCircle,
            title: 'How to Use',
            onTap: () => _showHowToUseDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.mail,
            title: 'Contact Support',
            onTap: () => _showContactSupportDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.star,
            title: 'Rate Us on Play Store',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coming soon! You will be able to rate us once the app is live on the Play Store.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[600], size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])) : null,
          trailing: const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
          onTap: onTap,
        ),
        Divider(indent: 70, endIndent: 20, height: 1, color: Colors.grey[200]),
      ],
    );
  }

  void _showBusinessProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _BusinessProfileForm(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    _showStyledDialog(
      context,
      title: 'About App',
      content: const Text(
        'App Name: BuildBill India\nVersion: 1.0.0\n\nThe ultimate billing and calculation app designed specifically for contractors, builders, and freelancers in India.',
        style: TextStyle(height: 1.5),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    _showStyledDialog(
      context,
      title: 'Privacy Policy',
      content: const Text(
        'We value your privacy. All your invoices, client details, and calculations are stored LOCALLY on your device. We do not collect, store, or share your personal business data with any third-party servers. The app uses the internet only to serve Google AdMob ads.',
        style: TextStyle(height: 1.5),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    _showStyledDialog(
      context,
      title: 'Terms & Conditions',
      content: const Text(
        "By using BuildBill India, you agree that the app is provided 'as is' for calculation and billing purposes. The developer is not responsible for any calculation errors or business losses. Please verify all totals before sending invoices to clients.",
        style: TextStyle(height: 1.5),
      ),
    );
  }

  void _showDataDeletionDialog(BuildContext context) {
    _showStyledDialog(
      context,
      title: 'Data Deletion Policy',
      content: const Text(
        'Since BuildBill India operates entirely offline, all your data (invoices, clients, calculations) is stored locally on your device. To delete all your data permanently, simply uninstall the app or clear the app data from your phone\'s settings. No data is kept on our servers.',
        style: TextStyle(height: 1.5),
      ),
    );
  }

  void _showHowToUseDialog(BuildContext context) {
    _showStyledDialog(
      context,
      title: 'How to Use',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFeatureInfo('📝', 'Billing', 'Create professional invoices, add measurement items, and calculate GST automatically.'),
            _buildFeatureInfo('🖩', 'Calculators', 'Use built-in calculators for construction materials and quick math.'),
            _buildFeatureInfo('🕒', 'History', 'View past invoices, check pending balances, and manage your clients.'),
            _buildFeatureInfo('💳', 'Payments', 'Track your paid and pending amounts easily.'),
            _buildFeatureInfo('📄', 'PDF Export', 'Generate beautiful PDF measurement sheets and share them directly via WhatsApp.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureInfo(String emoji, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    _showStyledDialog(
      context,
      title: 'Contact Support',
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Need help, have a suggestion, or want to report a bug?',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),
          SizedBox(height: 16),
          Text(
            'mailmeatsanjayrajput@gmail.com',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  void _showStyledDialog(BuildContext context, {required String title, required Widget content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _BusinessProfileForm extends StatefulWidget {
  const _BusinessProfileForm();

  @override
  State<_BusinessProfileForm> createState() => _BusinessProfileFormState();
}

class _BusinessProfileFormState extends State<_BusinessProfileForm> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _gstController;
  late TextEditingController _panController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().companyProfile;
    _nameController = TextEditingController(text: profile.name);
    _phoneController = TextEditingController(text: profile.phone);
    _emailController = TextEditingController(text: profile.email);
    _gstController = TextEditingController(text: profile.gstNo);
    _panController = TextEditingController(text: profile.panNo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _panController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Business Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField('Company Name', _nameController, LucideIcons.building),
            _buildField('Phone Number', _phoneController, LucideIcons.phone),
            _buildField('Email', _emailController, LucideIcons.mail),
            _buildField('GST Number', _gstController, LucideIcons.fileText),
            _buildField('PAN Number', _panController, LucideIcons.creditCard),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], foregroundColor: Colors.white),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  void _save() {
    final profile = CompanyProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      gstNo: _gstController.text,
      panNo: _panController.text,
      bankDetails: '', // Explicitly removed per requirement
    );
    context.read<AppState>().updateProfile(profile);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Business profile updated!'), behavior: SnackBarBehavior.floating),
    );
  }
}
