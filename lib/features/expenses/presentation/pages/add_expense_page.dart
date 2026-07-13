import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/entities/expense.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

@RoutePage()
class AddExpensePage extends StatelessWidget {
  // Optional expense — if provided, we are in edit mode
  final Expense? expense;

  const AddExpensePage({
    super.key,
    this.expense, // null = add mode, non-null = edit mode
  });

  @override
  Widget build(BuildContext context) {
    return _AddExpenseView(expense: expense);
  }
}

class _AddExpenseView extends StatefulWidget {
  final Expense? expense;

  const _AddExpenseView({this.expense});

  @override
  State<_AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<_AddExpenseView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _selectedType;
  late DateTime _selectedDate;

  // TODO: replace with category selector once UI is built
  final String _categoryId = 'general';

  // True when editing an existing expense
  bool get _isEditMode => widget.expense != null;

  @override
  void initState() {
    super.initState();

    // If editing, pre-fill all fields with existing expense data
    // If adding, start with empty/default values
    _titleController = TextEditingController(text: widget.expense?.title ?? '');
    _amountController = TextEditingController(
      // Only show amount if editing — empty string for add mode
      text: widget.expense != null
          ? widget.expense!.amount.toStringAsFixed(2)
          : '',
    );
    _noteController = TextEditingController(text: widget.expense?.note ?? '');
    _selectedType = widget.expense?.type ?? TransactionType.expense;
    _selectedDate = widget.expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditMode) {
      // EDIT MODE — preserve original id and createdAt
      // only update fields the user can change
      final updatedExpense = widget.expense!.copyWith(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        type: _selectedType,
        categoryId: _categoryId,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      context.read<ExpenseCubit>().updateExpense(updatedExpense);
    } else {
      // ADD MODE — create new expense, id generated in cubit
      final newExpense = Expense(
        id: '',
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        type: _selectedType,
        categoryId: _categoryId,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: DateTime.now(),
      );
      context.read<ExpenseCubit>().addExpense(newExpense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        // Title changes based on mode
        title: Text(
          _isEditMode ? 'Edit Transaction' : 'Add Transaction',
          style: AppTextStyles.sectionTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.maybePop(),
        ),
      ),
      body: BlocListener<ExpenseCubit, ExpenseState>(
        listener: (context, state) {
          state.whenOrNull(
            loaded: (_, __, ___) => context.maybePop(),
            error: (message) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.expense,
              ),
            ),
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Type Toggle ──────────────────────────────
                _TypeToggle(
                  selectedType: _selectedType,
                  onChanged: (type) => setState(() => _selectedType = type),
                ),
                const SizedBox(height: 24),

                // ── Amount Field ─────────────────────────────
                _buildLabel('Amount'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration(
                    '0.00',
                    prefixText: '${AppConstants.currency} ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Title Field ──────────────────────────────
                _buildLabel('Title'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('e.g. Morning coffee'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.trim().length < 2) {
                      return 'Title must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Date Picker ──────────────────────────────
                _buildLabel('Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Note Field ───────────────────────────────
                _buildLabel('Note (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Add a note...'),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // ── Save Button ──────────────────────────────
                BlocBuilder<ExpenseCubit, ExpenseState>(
                  builder: (context, state) {
                    final isLoading = state is ExpenseLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                // Button label changes based on mode
                                _isEditMode
                                    ? 'Update Transaction'
                                    : 'Save Transaction',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.label);
  }

  InputDecoration _inputDecoration(String hint, {String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      hintStyle: const TextStyle(color: AppColors.textHint),
      prefixStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: AppColors.expense),
    );
  }
}

// Type toggle — expense or income selector
class _TypeToggle extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  const _TypeToggle({required this.selectedType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Expense',
              isSelected: selectedType == TransactionType.expense,
              selectedColor: AppColors.expense,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Income',
              isSelected: selectedType == TransactionType.income,
              selectedColor: AppColors.income,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
