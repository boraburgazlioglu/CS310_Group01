import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<QuerySnapshot>? _expenseSubscription;
  String? _currentBandId;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void listenToExpenses(String bandId) {
    if (_currentBandId == bandId && _expenseSubscription != null) {
      return;
    }

    _currentBandId = bandId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _expenseSubscription?.cancel();

    _expenseSubscription = _expenseService.getExpenses(bandId).listen(
          (snapshot) {
        _expenses = snapshot.docs
            .map((doc) => Expense.fromFirestore(doc))
            .toList();

        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> addExpense({
    required String item,
    required double amount,
    required String bandId,
    required String createdBy,
  }) async {
    await _expenseService.addExpense(
      item: item,
      amount: amount,
      bandId: bandId,
      createdBy: createdBy,
    );
  }

  Future<void> updateExpense({
    required String id,
    required String item,
    required double amount,
  }) async {
    await _expenseService.updateExpense(
      id: id,
      item: item,
      amount: amount,
    );
  }

  Future<void> deleteExpense(String id) async {
    await _expenseService.deleteExpense(id);
  }

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }
}
