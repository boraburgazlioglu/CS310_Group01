import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text.dart';
import '../utils/padding.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();

  final List<Map<String, String>> _expenses = [
    {'item': 'Drumsticks', 'amount': '300 TL'},
    {'item': 'Taxi to rehearsal', 'amount': '180 TL'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = _amountController.text.trim();
      final item = _itemController.text.trim();

      setState(() {
        _expenses.add({
          'item': item,
          'amount': '$amount TL',
        });
      });

      _amountController.clear();
      _itemController.clear();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Success',
            style: AppTexts.headS,
          ),
          content: Text(
            'Expense added successfully.',
            style: AppTexts.bodyL,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: Text(
                'OK',
                style: AppTexts.button,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _removeExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'Expenses',
          style: AppTexts.headS,
        ),
      ),
      body: SingleChildScrollView(
        padding: AppPadding.allXL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Band Expenses',
              style: AppTexts.headL,
            ),
            const SizedBox(height: 20),

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
                    Text(
                      'Add Expense',
                      style: AppTexts.headS,
                    ),
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
                        child: Text(
                          'Add',
                          style: AppTexts.button,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Recent Expenses',
              style: AppTexts.headS,
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    title: Text(
                      _expenses[index]['item']!,
                      style: AppTexts.bodyL,
                    ),
                    subtitle: Text(
                      _expenses[index]['amount']!,
                      style: AppTexts.bodyM,
                    ),
                    trailing: IconButton(
                      onPressed: () => _removeExpense(index),
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.widgetDark,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: AppPadding.allL,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shared Status',
                    style: AppTexts.headS,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Berke paid 300 TL for drumsticks.',
                    style: AppTexts.bodyM,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Idris paid 180 TL for transportation.',
                    style: AppTexts.bodyM,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You can use this area to show who owes what.',
                    style: AppTexts.bodyM,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}