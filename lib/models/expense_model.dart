import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String item;
  final double amount;
  final String bandId;
  final String createdBy;
  final DateTime? createdAt;

  Expense({
    required this.id,
    required this.item,
    required this.amount,
    required this.bandId,
    required this.createdBy,
    this.createdAt,
  });

  // convert firestore document to Expense object
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      item: data['item'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      bandId: data['bandId'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // convert Expense object to map for firestore
  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'amount': amount,
      'bandId': bandId,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}