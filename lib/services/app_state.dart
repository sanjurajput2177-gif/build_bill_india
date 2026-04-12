import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  List<Invoice> invoices = [];
  List<Client> clients = [];
  List<Payment> payments = [];
  CompanyProfile companyProfile = CompanyProfile(
    name: 'BuildBill India',
    phone: '',
    email: '',
    gstNo: '',
    panNo: '',
    bankDetails: '',
  );

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final invoicesJson = prefs.getString('buildbill_invoices');
    if (invoicesJson != null) {
      invoices = (jsonDecode(invoicesJson) as List).map((e) => Invoice.fromMap(e)).toList();
    }

    final clientsJson = prefs.getString('buildbill_clients');
    if (clientsJson != null) {
      clients = (jsonDecode(clientsJson) as List).map((e) => Client.fromMap(e)).toList();
    }

    final paymentsJson = prefs.getString('buildbill_payments');
    if (paymentsJson != null) {
      payments = (jsonDecode(paymentsJson) as List).map((e) => Payment.fromMap(e)).toList();
    }

    final profileJson = prefs.getString('buildbill_profile');
    if (profileJson != null) {
      companyProfile = CompanyProfile.fromMap(jsonDecode(profileJson));
    }
    
    notifyListeners();
  }

  // Financial Summary Logic
  double getClientTotalBilled(String clientName) {
    return invoices
        .where((inv) => inv.clientName == clientName)
        .fold(0.0, (sum, inv) => sum + inv.totalAmount);
  }

  double getClientTotalReceived(String clientName) {
    return payments
        .where((p) => p.clientName == clientName)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double getClientBalance(String clientName) {
    return getClientTotalBilled(clientName) - getClientTotalReceived(clientName);
  }

  Future<void> saveInvoice(Invoice invoice) async {
    int index = invoices.indexWhere((inv) => inv.id == invoice.id);
    if (index != -1) {
      invoices[index] = invoice;
    } else {
      invoices.insert(0, invoice);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('buildbill_invoices', jsonEncode(invoices.map((e) => e.toMap()).toList()));
    notifyListeners();
  }

  Future<void> updateProfile(CompanyProfile profile) async {
    companyProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('buildbill_profile', jsonEncode(profile.toMap()));
    notifyListeners();
  }

  Future<void> addClient(Client client) async {
    clients.add(client);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('buildbill_clients', jsonEncode(clients.map((e) => e.toMap()).toList()));
    notifyListeners();
  }

  Future<void> deleteInvoice(String id) async {
    invoices.removeWhere((inv) => inv.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('buildbill_invoices', jsonEncode(invoices.map((e) => e.toMap()).toList()));
    notifyListeners();
  }

  Future<void> addPayment(Payment payment) async {
    payments.insert(0, payment);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('buildbill_payments', jsonEncode(payments.map((e) => e.toMap()).toList()));
    notifyListeners();
  }

  Future<void> updatePayment(Payment payment) async {
    int index = payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      payments[index] = payment;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('buildbill_payments', jsonEncode(payments.map((e) => e.toMap()).toList()));
      notifyListeners();
    }
  }

  Future<void> deletePayment(String id) async {
    payments.removeWhere((p) => p.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('buildbill_payments', jsonEncode(payments.map((e) => e.toMap()).toList()));
    notifyListeners();
  }
}
