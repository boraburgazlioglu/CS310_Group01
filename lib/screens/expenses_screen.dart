import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../utils/colors.dart';
import '../utils/text.dart';
import '../utils/padding.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  bool _isListening = false;

  // placeholder until auth is integrated
  final String _bandId = 'group1';
  final String _createdBy = 'Idris';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isListening) {
      Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).listenToExpenses(_bandId);

      _isListening = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.trim());
      final item = _itemController.text.trim();

      Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).addExpense(
        item: item,
        amount: amount,
        bandId: _bandId,
        createdBy: _createdBy,
      );

      _amountController.clear();
      _itemController.clear();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Success', style: AppTexts.headS),
          content: Text('Expense added successfully.', style: AppTexts.bodyL),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('OK', style: AppTexts.button),
            ),
          ],
        ),
      );
    }
  }

  void _deleteExpense(String id) {
    Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).deleteExpense(id);
  }

  void _showEditDialog(Expense expense) {
    final itemController = TextEditingController(text: expense.item);
    final amountController =
    TextEditingController(text: expense.amount.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Edit Expense', style: AppTexts.headS),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemController,
              style: AppTexts.bodyL,
              decoration: InputDecoration(
                hintText: 'Item',
                hintStyle: AppTexts.bodyM,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              style: AppTexts.bodyL,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Amount',
                hintStyle: AppTexts.bodyM,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTexts.button),
          ),
          TextButton(
            onPressed: () {
              // update in firestore
              Provider.of<ExpenseProvider>(
                context,
                listen: false,
              ).updateExpense(
                id: expense.id,
                item: itemController.text.trim(),
                amount: double.tryParse(amountController.text.trim()) ?? expense.amount,
              );
              Navigator.pop(ctx);
            },
            child: Text('Save', style: AppTexts.button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: BandmateHeader(),
      body: SingleChildScrollView(
        padding: AppPadding.allXL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Band Expenses', style: AppTexts.headL),
            const SizedBox(height: 20),

            // add expense form
            Container(
              width: double.infinity,
              padding: AppPadding.allL,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Expense', style: AppTexts.headS),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      style: AppTexts.bodyL,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        hintStyle: AppTexts.bodyM,
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _itemController,
                      style: AppTexts.bodyL,
                      decoration: InputDecoration(
                        hintText: 'Enter expense item',
                        hintStyle: AppTexts.bodyM,
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an item';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: AppPadding.vertM,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Add', style: AppTexts.button),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('Recent Expenses', style: AppTexts.headS),
            const SizedBox(height: 12),

            // real-time expense list from firestore

            Consumer<ExpenseProvider>(
              builder: (context, expenseProvider, child) {
                if (expenseProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (expenseProvider.errorMessage != null) {
                  return Text(
                    expenseProvider.errorMessage!,
                    style: AppTexts.bodyM,
                  );
                }

                if (expenseProvider.expenses.isEmpty) {
                  return Text('No expenses yet.', style: AppTexts.bodyM);
                }

                final expenses = expenseProvider.expenses;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];

                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        title: Text(expense.item, style: AppTexts.bodyL),
                        subtitle: Text(
                          '${expense.amount.toStringAsFixed(0)} TL',
                          style: AppTexts.bodyM,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showEditDialog(expense),
                              icon: const Icon(Icons.edit_outlined),
                              color: AppColors.primary,
                            ),
                            IconButton(
                              onPressed: () => _deleteExpense(expense.id),
                              icon: const Icon(Icons.delete_outline),
                              color: AppColors.widgetDark,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyNavBar(currentIndex: 2),
    );
  }
}