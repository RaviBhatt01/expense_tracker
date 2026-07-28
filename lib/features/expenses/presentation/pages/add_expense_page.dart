import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/expense.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/category_picker.dart';

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

  // null means nothing selected yet
  String? _selectedCategoryId;

  // Receipt image state
  File? _receiptFile;
  String? _receiptUrl; // existing URL when editing
  bool _isUploadingReceipt = false;

  // Tracks if form was submitted — prevents false navigation
  bool _isSubmitting = false;

  // True when editing an existing expense
  bool get _isEditMode => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title ?? '');
    _amountController = TextEditingController(
      text: widget.expense != null
          ? widget.expense!.amount.toStringAsFixed(2)
          : '',
    );
    _noteController = TextEditingController(text: widget.expense?.note ?? '');
    _selectedType = widget.expense?.type ?? TransactionType.expense;
    _selectedDate = widget.expense?.date ?? DateTime.now();

    // Pre-select category and receipt when editing
    _selectedCategoryId = widget.expense?.categoryId;
    _receiptUrl = widget.expense?.receiptUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Use dark or light theme based on current app theme
        return Theme(
          data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: Theme.of(context).cardColor,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: AppColors.primary,
                    surface: Theme.of(context).cardColor,
                    onSurface: const Color(0xFF111114),
                  ),
            dialogBackgroundColor: Theme.of(context).cardColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Pick image from gallery or camera
  Future<void> _pickReceipt(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 70, // compress to reduce storage usage
      maxWidth: 1200,
    );

    if (image != null) {
      setState(() => _receiptFile = File(image.path));
    }
  }

  // ignore: unused_element
  void _showReceiptOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickReceipt(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickReceipt(ImageSource.gallery);
              },
            ),
            if (_receiptFile != null || _receiptUrl != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.expense.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.expense,
                  ),
                ),
                title: const Text(
                  'Remove Receipt',
                  style: TextStyle(color: AppColors.expense),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _receiptFile = null;
                    _receiptUrl = null;
                  });
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Upload receipt to Firebase Storage and return URL
  Future<String?> _uploadReceipt() async {
    if (_receiptFile == null) return _receiptUrl;

    setState(() => _isUploadingReceipt = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('receipts')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(_receiptFile!);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt upload failed: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isUploadingReceipt = false);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final receiptUrl = await _uploadReceipt();

    if (!mounted) return;

    if (_isEditMode) {
      final updatedExpense = widget.expense!.copyWith(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        type: _selectedType,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        receiptUrl: receiptUrl,
      );
      context.read<ExpenseCubit>().updateExpense(updatedExpense);
    } else {
      final newExpense = Expense(
        id: '',
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        type: _selectedType,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        receiptUrl: receiptUrl,
        createdAt: DateTime.now(),
      );
      context.read<ExpenseCubit>().addExpense(newExpense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        // Title changes based on mode
        title: Text(
          _isEditMode ? 'Edit Transaction' : 'Add Transaction',
          style: AppTextStyles.sectionTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.maybePop(),
        ),
      ),
      body: BlocListener<ExpenseCubit, ExpenseState>(
        listenWhen: (previous, current) {
          // Only listen when we submitted AND state changed to loaded
          return _isSubmitting && current is ExpenseLoaded;
        },
        listener: (context, state) {
          state.whenOrNull(
            loaded: (_, _, __, ___, ____, _____, ______) {
              if (!mounted) return;
              setState(() => _isSubmitting = false);
              context.maybePop();
            },
            error: (message) {
              if (!mounted) return;
              setState(() => _isSubmitting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.expense,
                ),
              );
            },
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
                  onChanged: (type) {
                    setState(() {
                      _selectedType = type;
                      // Reset category when switching type
                      // expense categories don't apply to income and vice versa
                      _selectedCategoryId = null;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // ── Category Picker ──────────────────────────
                _buildLabel('Category'),
                const SizedBox(height: 8),
                CategoryPicker(
                  selectedType: _selectedType,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (id) {
                    setState(() => _selectedCategoryId = id);
                  },
                ),
                // Manage Categories button below picker
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        context.router.push(const CategoryManagementRoute()),
                    icon: const Icon(
                      Icons.settings_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Manage Categories',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormatter.full(_selectedDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
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
                  decoration: _inputDecoration('Add a note...'),
                  maxLines: 3,
                  // No validator — field is optional
                ),
                const SizedBox(height: 20),

                // // ── Receipt / Invoice ────────────────────────
                // _buildLabel('Receipt / Invoice (optional)'),
                // const SizedBox(height: 8),
                // _ReceiptPicker(
                //   receiptFile: _receiptFile,
                //   receiptUrl: _receiptUrl,
                //   isUploading: _isUploadingReceipt,
                //   onTap: _showReceiptOptions,
                // ),
                // const SizedBox(height: 32),

                // ── Save Button ──────────────────────────────
                BlocBuilder<ExpenseCubit, ExpenseState>(
                  builder: (context, state) {
                    final isLoading =
                        state is ExpenseLoading || _isUploadingReceipt;
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
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
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
                const SizedBox(height: 20),
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
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: AppColors.expense),
    );
  }
}

// Receipt picker widget — shows image preview or add button
// ignore: unused_element
class _ReceiptPicker extends StatelessWidget {
  final File? receiptFile;
  final String? receiptUrl;
  final bool isUploading;
  final VoidCallback onTap;

  const _ReceiptPicker({
    required this.receiptFile,
    required this.receiptUrl,
    required this.isUploading,
    required this.onTap,
  });

  bool get hasReceipt => receiptFile != null || receiptUrl != null;

  @override
  Widget build(BuildContext context) {
    if (isUploading) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
              SizedBox(height: 8),
              Text('Uploading receipt...', style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      );
    }

    if (hasReceipt) {
      // Show image preview
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: receiptFile != null
                  ? Image.file(
                      receiptFile!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      receiptUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
            ),
            // Edit overlay
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Change',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show add receipt button
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add receipt or invoice',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
