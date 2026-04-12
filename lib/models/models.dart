import 'dart:convert';

class Dimension {
  final int ft;
  final int inch;

  Dimension({required this.ft, required this.inch});

  double get toDecimalFeet => ft + (inch / 12.0);

  Map<String, dynamic> toMap() => {'ft': ft, 'inch': inch};
  factory Dimension.fromMap(Map<String, dynamic> map) => Dimension(
        ft: map['ft'] ?? 0,
        inch: map['inch'] ?? 0,
      );
}

class BillItem {
  final String id;
  final String description;
  final String type; // 'volume', 'area', 'sqyard'
  final Dimension length;
  final Dimension width;
  final Dimension? height;
  final int quantity;
  final double rate;
  final double totalUnits;
  final double subtotal;

  BillItem({
    required this.id,
    required this.description,
    required this.type,
    required this.length,
    required this.width,
    this.height,
    required this.quantity,
    required this.rate,
    required this.totalUnits,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'type': type,
        'length': length.toMap(),
        'width': width.toMap(),
        'height': height?.toMap(),
        'quantity': quantity,
        'rate': rate,
        'totalUnits': totalUnits,
        'subtotal': subtotal,
      };

  factory BillItem.fromMap(Map<String, dynamic> map) => BillItem(
        id: map['id'],
        description: map['description'],
        type: map['type'],
        length: Dimension.fromMap(map['length']),
        width: Dimension.fromMap(map['width']),
        height: map['height'] != null ? Dimension.fromMap(map['height']) : null,
        quantity: map['quantity'],
        rate: (map['rate'] as num).toDouble(),
        totalUnits: (map['totalUnits'] as num).toDouble(),
        subtotal: (map['subtotal'] as num).toDouble(),
      );
}

class Payment {
  final String id;
  final String invoiceId;
  final String clientName;
  final double amount;
  final DateTime date;
  final String mode; // 'Cash', 'Cheque', 'UPI'

  Payment({
    required this.id,
    required this.invoiceId,
    required this.clientName,
    required this.amount,
    required this.date,
    required this.mode,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoiceId': invoiceId,
        'clientName': clientName,
        'amount': amount,
        'date': date.toIso8601String(),
        'mode': mode,
      };

  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
        id: map['id'],
        invoiceId: map['invoiceId'],
        clientName: map['clientName'],
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date']),
        mode: map['mode'],
      );
}

class Invoice {
  final String id;
  final String clientName;
  final String clientPhone;
  final String? clientEmail;
  final String? clientAddress;
  final DateTime date;
  final List<BillItem> items;
  final double gstPercentage;
  final double subtotal;
  final double gstAmount;
  final double totalAmount;
  final List<Payment> payments;
  final double balance;

  Invoice({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
    this.clientAddress,
    required this.date,
    required this.items,
    required this.gstPercentage,
    required this.subtotal,
    required this.gstAmount,
    required this.totalAmount,
    this.payments = const [],
    required this.balance,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'clientEmail': clientEmail,
        'clientAddress': clientAddress,
        'date': date.toIso8601String(),
        'items': items.map((x) => x.toMap()).toList(),
        'gstPercentage': gstPercentage,
        'subtotal': subtotal,
        'gstAmount': gstAmount,
        'totalAmount': totalAmount,
        'payments': payments.map((x) => x.toMap()).toList(),
        'balance': balance,
      };

  factory Invoice.fromMap(Map<String, dynamic> map) => Invoice(
        id: map['id'],
        clientName: map['clientName'],
        clientPhone: map['clientPhone'],
        clientEmail: map['clientEmail'],
        clientAddress: map['clientAddress'],
        date: DateTime.parse(map['date']),
        items: List<BillItem>.from(map['items']?.map((x) => BillItem.fromMap(x))),
        gstPercentage: (map['gstPercentage'] as num).toDouble(),
        subtotal: (map['subtotal'] as num).toDouble(),
        gstAmount: (map['gstAmount'] as num).toDouble(),
        totalAmount: (map['totalAmount'] as num).toDouble(),
        payments: map['payments'] != null 
            ? List<Payment>.from(map['payments']?.map((x) => Payment.fromMap(x)))
            : [],
        balance: (map['balance'] as num).toDouble(),
      );
}

class Client {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final DateTime createdAt;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Client.fromMap(Map<String, dynamic> map) => Client(
        id: map['id'],
        name: map['name'],
        phone: map['phone'],
        email: map['email'],
        address: map['address'],
        createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      );
}

class CompanyProfile {
  final String name;
  final String phone;
  final String email;
  final String gstNo;
  final String panNo;
  final String bankDetails;

  CompanyProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.gstNo,
    required this.panNo,
    required this.bankDetails,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'email': email,
        'gstNo': gstNo,
        'panNo': panNo,
        'bankDetails': bankDetails,
      };

  factory CompanyProfile.fromMap(Map<String, dynamic> map) => CompanyProfile(
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        email: map['email'] ?? '',
        gstNo: map['gstNo'] ?? '',
        panNo: map['panNo'] ?? '',
        bankDetails: map['bankDetails'] ?? '',
      );
}
