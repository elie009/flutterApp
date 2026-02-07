import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'package:go_router/go_router.dart';
import '../../utils/navigation_helper.dart';
import '../../services/data_service.dart';
import '../../models/bill.dart';
import '../../widgets/bottom_nav_bar_figma.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _providerController = TextEditingController();
  String? _selectedCategory;
  String _selectedFrequency = 'MONTHLY';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  String? _errorMessage;

  final DataService _dataService = DataService();

  final List<String> _billCategories = [
    'Electricity',
    'Water',
    'Gas',
    'Internet',
    'Phone',
    'Rent',
    'Insurance',
    'Credit Card',
    'Loan Payment',
    'Other'
  ];

  static const List<String> _frequencyOptions = [
    'MONTHLY',
    'WEEKLY',
    'BIWEEKLY',
    'YEARLY',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _providerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      setState(() => _errorMessage = 'Please select a category');
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Please enter a valid amount greater than 0');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _dataService.createBill(
        billName: _titleController.text.trim(),
        billType: _selectedCategory!,
        amount: amount,
        dueDate: _selectedDate,
        frequency: _selectedFrequency,
        notes: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        provider: _providerController.text.trim().isEmpty
            ? null
            : _providerController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill created successfully'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/bills');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      bottomNavigationBar: BottomNavBarFigma(currentIndex: 3),
      body: Form(
        key: _formKey,
        child: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: AppTheme.primaryColor,
        ),
        child: Stack(
          children: [

               // Title "Add bills" (centered)
            Positioned(
              left: 0,
              right: 0,
              top: 64,
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Add Bills',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700, // Changed to bold
                          height: 1.10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Notification icon
            Positioned(
              left: 364,
              top: 51,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.all(Radius.circular(25.71)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications,
                    color: Color(0xFF093030),
                    size: 21,
                  ),
                ),
              ),
            ),
            // Back button (use go to avoid "nothing to pop" when opened via go/goNamed)
            Positioned(
              left: 38,
              top: 69,
              child: GestureDetector(
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) context.go('/bills');
                  });
                },
                child: Container(
                  width: 19,
                  height: 16,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFF1FFF3),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // White bottom section
            Positioned(
              left: 0,
              top: 176,
              width: 430,
              height: 800,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
              ),
            ),
       

            // Date field
            Positioned(
              left: 37,
              top: 198 , // moved down by 12px to account for the gap
              child: Container(
                width: 356,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ,${_selectedDate.year}',
                          style: const TextStyle(
                            color: Color(0xFF093030),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          width: 23.66,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(9.13),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFF093030),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Category dropdown
            Positioned(
              left: 37,
              top: 278,
              child: Container(
                width: 356,
                height: 48,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Opacity(
                      opacity: 0.50,
                      child: Text(
                        'Select the category',
                        style: TextStyle(
                          color: Color(0xFF0E3E3E),
                          fontSize: 15.68,
                          fontFamily: 'League Spartan',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF093030)),
                    style: const TextStyle(
                      color: Color(0xFF0E3E3E),
                      fontSize: 15.68,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.w400,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    items: _billCategories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Opacity(
                          opacity: 0.50,
                          child: Text(value),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Frequency dropdown (required by API)
            Positioned(
              left: 37,
              top: 358,
              child: Container(
                width: 356,
                height: 48,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFrequency,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF093030)),
                    style: const TextStyle(
                      color: Color(0xFF0E3E3E),
                      fontSize: 15.68,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.w400,
                    ),
                    onChanged: _isSubmitting
                        ? null
                        : (String? newValue) {
                            setState(() => _selectedFrequency = newValue ?? 'MONTHLY');
                          },
                    items: _frequencyOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Amount field
            Positioned(
              left: 37,
              top: 449,
              child: Container(
                width: 356,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(
                      color: Color(0xFF093030),
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: const Color(0xFFDFF7E2),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: const Color(0xFFDFF7E2),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
              ),
            ),

            // Bill name field
            Positioned(
              left: 37,
              top: 533,
              child: Container(
                width: 356,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextFormField(
                  controller: _titleController,
                  style: const TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Electricity, Rent',
                    hintStyle: const TextStyle(
                      color: Color(0xFF093030),
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: const Color(0xFFDFF7E2),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: const Color(0xFFDFF7E2),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a bill name';
                    }
                    return null;
                  },
                ),
              ),
            ),

            // Notes / Description field
            Positioned(
              left: 37,
              top: 617,
              child: Container(
                width: 356,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Notes (optional)',
                    hintStyle: const TextStyle(
                      color: Color(0xFF093030),
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    filled: true,
                    fillColor: const Color(0xFFDFF7E2),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: const Color(0xFFDFF7E2),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Error message
            if (_errorMessage != null)
              Positioned(
                left: 37,
                top: 728,
                right: 37,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            color: Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Save button
            Positioned(
              left: 123,
              top: 800,
              child: GestureDetector(
                onTap: _isSubmitting ? null : _saveBill,
                child: Container(
                  width: 169,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _isSubmitting
                        ? AppTheme.primaryColor.withOpacity(0.6)
                        : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF093030),
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            color: Color(0xFF093030),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),

            // Field labels
            const Positioned(
              left: 37,
              top: 175,
              child: Text(
                'Due date',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 37,
              top: 255,
              child: Text(
                'Category',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 37,
              top: 335,
              child: Text(
                'Frequency',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 37,
              top: 426,
              child: Text(
                'Amount',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 37,
              top: 510,
              child: Text(
                'Bill name',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

           

          ],
        ),
      ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
