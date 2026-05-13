import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // expenses collection
  CollectionReference get _expenses => _db.collection('expenses');

  // add new expense to firestore
  Future<void> addExpense({
    required String item,
    required double amount,
    required String bandId,
    required String createdBy,
  }) async {
    await _expenses.add({
      'item': item,
      'amount': amount,
      'bandId': bandId,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // real-time stream of expenses for a band
  Stream<QuerySnapshot> getExpenses(String bandId) {
    return _expenses
        .where('bandId', isEqualTo: bandId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // delete by document id
  Future<void> deleteExpense(String id) async {
    await _expenses.doc(id).delete();
  }

  // update item and amount
  Future<void> updateExpense({
    required String id,
    required String item,
    required double amount,
  }) async {
    await _expenses.doc(id).update({
      'item': item,
      'amount': amount,
    });
  }
}