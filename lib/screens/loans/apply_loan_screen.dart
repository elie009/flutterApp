import 'package:flutter/material.dart';

import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class ApplyLoanScreen extends StatefulWidget {
  const ApplyLoanScreen({super.key});

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  final List<GlobalKey<FormState>> _formKeys = List.generate(2, (_) => GlobalKey<FormState>());
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _termController = TextEditingController();
  final TextEditingController _customPurposeController = TextEditingController();
  final TextEditingController _downPaymentController = TextEditingController();
  final TextEditingController _processingFeeController = TextEditingController();
  final TextEditingController _monthlyIncomeController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();

  int _currentStep = 0;
  bool _isSubmitting = false;
  String _selectedPurpose = 'Car Loan';
  String _selectedEmploymentStatus = 'employed';
  String? _selectedInterestMethod;
  String _selectedLoanType = 'PERSONAL';

  static const List<String> _loanPurposeOptions = [
    'Car Loan',
    'Housing Loan',
    'Medical',
    'Education',
    'Vacation',
    'Personal',
    'Other',
  ];

  static const Map<String, String> _interestMethodLabels = {
    'FLAT_RATE': 'Flat Rate',
    'AMORTIZED': 'Amortized',
  };

  static const List<String> _employmentStatusOptions = [
    'employed',
    'self-employed',
    'unemployed',
    'retired',
    'student',
  ];

  static const List<Map<String, String>> _loanTypeOptions = [
    {'value': 'PERSONAL', 'label': 'Personal Loan'},
    {'value': 'MORTGAGE', 'label': 'Mortgage'},
    {'value': 'AUTO', 'label': 'Auto Loan'},
    {'value': 'STUDENT', 'label': 'Student Loan'},
    {'value': 'BUSINESS', 'label': 'Business Loan'},
    {'value': 'CREDIT_CARD', 'label': 'Credit Card'},
    {'value': 'LINE_OF_CREDIT', 'label': 'Line of Credit'},
    {'value': 'OTHER', 'label': 'Other'},
  ];

  bool get _shouldShowCustomPurpose => _selectedPurpose == 'Other';

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  void _handleStepContinue() {
    final isLastStep = _currentStep == _formKeys.length - 1;
    if (_currentStep < _formKeys.length) {
      final currentForm = _formKeys[_currentStep].currentState;
      if (currentForm != null && !currentForm.validate()) {
        return;
      }
    }

    if (_shouldShowCustomPurpose && _currentStep == 0) {
      if (_customPurposeController.text.trim().isEmpty) {
        NavigationHelper.showSnackBar(
          context,
          'Please specify the custom loan purpose.',
          backgroundColor: AppTheme.errorColor,
        );
        return;
      }
    }

    if (!isLastStep) {
      _goToStep(_currentStep + 1);
    } else {
      _submitLoanApplication();
    }
  }

  void _handleStepCancel() {
    if (_currentStep == 0) {
      Navigator.of(context).maybePop();
    } else {
      _goToStep(_currentStep - 1);
    }
  }

  Future<void> _submitLoanApplication() async {
    if (_isSubmitting) return;

    final principal = double.tryParse(_principalController.text.replaceAll(',', ''));
    final interestRate = double.tryParse(_interestRateController.text);
    final term = int.tryParse(_termController.text);
    final monthlyIncome = double.tryParse(_monthlyIncomeController.text.replaceAll(',', ''));
    final downPayment = _downPaymentController.text.isEmpty
        ? null
        : double.tryParse(_downPaymentController.text.replaceAll(',', ''));
    final processingFee = _processingFeeController.text.isEmpty
        ? null
        : double.tryParse(_processingFeeController.text.replaceAll(',', ''));

    if (principal == null || principal <= 0) {
      NavigationHelper.showSnackBar(
        context,
        'Please enter a valid principal amount.',
        backgroundColor: AppTheme.errorColor,
      );
      return;
    }

    if (interestRate == null || interestRate <= 0) {
      NavigationHelper.showSnackBar(
        context,
        'Please enter a valid interest rate.',
        backgroundColor: AppTheme.errorColor,
      );
      return;
    }

    if (term == null || term <= 0) {
      NavigationHelper.showSnackBar(
        context,
        'Please enter a valid loan term.',
        backgroundColor: AppTheme.errorColor,
      );
      return;
    }

    if (monthlyIncome == null || monthlyIncome <= 0) {
      NavigationHelper.showSnackBar(
        context,
        'Please enter your monthly income.',
        backgroundColor: AppTheme.errorColor,
      );
      return;
    }

    final purposeValue = _shouldShowCustomPurpose
        ? _customPurposeController.text.trim()
        : _selectedPurpose.toLowerCase();

    if (purposeValue.isEmpty) {
      NavigationHelper.showSnackBar(
        context,
        'Please choose a loan purpose.',
        backgroundColor: AppTheme.errorColor,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await DataService().applyForLoan(
        principal: principal,
        interestRate: interestRate,
        term: term,
        purpose: purposeValue,
        monthlyIncome: monthlyIncome,
        employmentStatus: _selectedEmploymentStatus,
        additionalInfo: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
        downPayment: downPayment,
        processingFee: processingFee,
        interestComputationMethod: _selectedInterestMethod,
        loanType: _selectedLoanType,
      );

      if (!mounted) return;

      NavigationHelper.showSnackBar(
        context,
        'Loan application submitted successfully!',
        backgroundColor: AppTheme.successColor,
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      NavigationHelper.showSnackBar(
        context,
        'Failed to submit loan application: $e',
        backgroundColor: AppTheme.errorColor,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildStepControls(BuildContext context, ControlsDetails details) {
    final isLastStep = _currentStep == 2;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : details.onStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSubmitting && isLastStep
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(isLastStep ? 'Submit Application' : 'Continue'),
            ),
          ),
          const SizedBox(width: 12),
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : details.onStepCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Back'),
              ),
            )
          else
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.of(context).maybePop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cancel'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Loan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _handleStepContinue,
          onStepCancel: _handleStepCancel,
          controlsBuilder: _buildStepControls,
          steps: [
            Step(
              title: const Text('Loan Details'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.editing,
              content: Form(
                key: _formKeys[0],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _principalController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Loan Amount',
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: 'Enter loan principal',
                      ),
                      validator: (value) {
                        final parsed = double.tryParse((value ?? '').replaceAll(',', ''));
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _interestRateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Interest Rate (%)',
                        prefixIcon: Icon(Icons.percent),
                        hintText: 'e.g., 8.5',
                      ),
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid interest rate';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _termController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Term (months)',
                        prefixIcon: Icon(Icons.schedule),
                        hintText: 'e.g., 48',
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter loan term in months';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedPurpose,
                      decoration: const InputDecoration(
                        labelText: 'Loan Purpose',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: _loanPurposeOptions
                          .map(
                            (purpose) => DropdownMenuItem<String>(
                              value: purpose,
                              child: Text(purpose),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedPurpose = value;
                          if (!_shouldShowCustomPurpose) {
                            _customPurposeController.clear();
                          }
                        });
                      },
                    ),
                    if (_shouldShowCustomPurpose) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customPurposeController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Purpose',
                          hintText: 'Describe the loan purpose',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedLoanType,
                      decoration: const InputDecoration(
                        labelText: 'Loan Type',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _loanTypeOptions
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type['value'],
                              child: Text(type['label']!),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedLoanType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      value: _selectedInterestMethod,
                      decoration: const InputDecoration(
                        labelText: 'Interest Computation',
                        prefixIcon: Icon(Icons.calculate_outlined),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: const Text('Select method (optional)'),
                        ),
                        ..._interestMethodLabels.entries
                            .map(
                              (entry) => DropdownMenuItem<String?>(
                                value: entry.key,
                                child: Text(entry.value),
                              ),
                            )
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedInterestMethod = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _downPaymentController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Down Payment (optional)',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _processingFeeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Processing Fee (optional)',
                        prefixIcon: Icon(Icons.receipt_long_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: const Text('Financial Snapshot'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : (_currentStep == 1 ? StepState.editing : StepState.indexed),
              content: Form(
                key: _formKeys[1],
                child: Column(
                  children: [
                    TextFormField(
                      controller: _monthlyIncomeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Monthly Income',
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      ),
                      validator: (value) {
                        final parsed = double.tryParse((value ?? '').replaceAll(',', ''));
                        if (parsed == null || parsed <= 0) {
                          return 'Enter your monthly income';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedEmploymentStatus,
                      decoration: const InputDecoration(
                        labelText: 'Employment Status',
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                      items: _employmentStatusOptions
                          .map(
                            (status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status[0].toUpperCase() + status.substring(1)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedEmploymentStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _additionalInfoController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes (optional)',
                        alignLabelWithHint: true,
                        hintText: 'Any extra information or preferences',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'We use your income and employment details to evaluate eligibility and recommended repayment plans.',
                              style: TextStyle(
                                color: AppTheme.primaryColor.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: const Text('Review & Submit'),
              isActive: _currentStep >= 2,
              state: _currentStep == 2 ? StepState.editing : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Loan Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildReviewRow(
                          'Principal',
                          _principalController.text.isEmpty
                              ? '--'
                              : Formatters.formatCurrency(
                                  double.tryParse(_principalController.text.replaceAll(',', '')) ?? 0,
                                ),
                        ),
                        _buildReviewRow('Interest Rate', _interestRateController.text.isEmpty ? '--' : '${_interestRateController.text}%'),
                        _buildReviewRow('Term', _termController.text.isEmpty ? '--' : '${_termController.text} months'),
                        _buildReviewRow(
                          'Purpose',
                          _shouldShowCustomPurpose
                              ? _customPurposeController.text
                              : _selectedPurpose,
                        ),
                        if (_selectedInterestMethod != null)
                          _buildReviewRow(
                            'Interest Method',
                            _interestMethodLabels[_selectedInterestMethod!] ?? _selectedInterestMethod!,
                          ),
                        if (_downPaymentController.text.isNotEmpty)
                          _buildReviewRow(
                            'Down Payment',
                            Formatters.formatCurrency(
                              double.tryParse(_downPaymentController.text.replaceAll(',', '')) ?? 0,
                            ),
                          ),
                        if (_processingFeeController.text.isNotEmpty)
                          _buildReviewRow(
                            'Processing Fee',
                            Formatters.formatCurrency(
                              double.tryParse(_processingFeeController.text.replaceAll(',', '')) ?? 0,
                            ),
                          ),
                        _buildReviewRow(
                          'Monthly Income',
                          _monthlyIncomeController.text.isEmpty
                              ? '--'
                              : Formatters.formatCurrency(
                                  double.tryParse(_monthlyIncomeController.text.replaceAll(',', '')) ?? 0,
                                ),
                        ),
                        _buildReviewRow(
                          'Employment Status',
                          _selectedEmploymentStatus[0].toUpperCase() + _selectedEmploymentStatus.substring(1),
                        ),
                        if (_additionalInfoController.text.isNotEmpty)
                          _buildReviewRow('Notes', _additionalInfoController.text),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Submitting this application will send it securely to our loan processing system for review.',
                            style: TextStyle(
                              color: AppTheme.primaryColor.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '--' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestRateController.dispose();
    _termController.dispose();
    _customPurposeController.dispose();
    _downPaymentController.dispose();
    _processingFeeController.dispose();
    _monthlyIncomeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }
}

