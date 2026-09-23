import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/subscription_plan.dart';
import '../../providers/app_provider.dart';

class PaymentCheckoutModal extends StatefulWidget {
  final SubscriptionPlan plan;

  const PaymentCheckoutModal({super.key, required this.plan});

  static Future<bool?> show(BuildContext context, SubscriptionPlan plan) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentCheckoutModal(plan: plan),
    );
    if (result == true && context.mounted) {
      _showPaymentSuccessDialog(context, plan);
    }
    return result;
  }

  static void _showPaymentSuccessDialog(BuildContext context, SubscriptionPlan plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF7F4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.secondaryTeal, size: 54),
            ),
            const SizedBox(height: 18),
            const Text(
              'Payment Confirmed! 🎉',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.mainText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your account has been upgraded to ${plan.title}. All premium AI evaluators, simulated environments, and unlimited speech practice are now fully unlocked!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCoral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Start Practicing with Pro Privileges', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<PaymentCheckoutModal> createState() => _PaymentCheckoutModalState();
}

enum PaymentMethodType { mobileMoney, card, appleGooglePay }

class _PaymentCheckoutModalState extends State<PaymentCheckoutModal> {
  PaymentMethodType _selectedMethod = PaymentMethodType.mobileMoney;
  String _selectedMoMoProvider = 'MTN Mobile Money';
  bool _isYearlyBilling = false;
  bool _isProcessing = false;

  final TextEditingController _phoneController = TextEditingController(text: '+237 671 234 567');
  final TextEditingController _cardNumController = TextEditingController(text: '4532 •••• •••• 8892');
  final TextEditingController _cardHolderController = TextEditingController(text: 'Amina Bello');
  final TextEditingController _cardExpiryController = TextEditingController(text: '08/28');
  final TextEditingController _cardCvvController = TextEditingController(text: '342');

  @override
  void dispose() {
    _phoneController.dispose();
    _cardNumController.dispose();
    _cardHolderController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  int get _amountInFCFA {
    if (widget.plan.tier == SubscriptionTier.pro) {
      return _isYearlyBilling ? 35000 : 3500;
    } else if (widget.plan.tier == SubscriptionTier.plus) {
      return _isYearlyBilling ? 55000 : 5500;
    }
    return 0;
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    final provider = Provider.of<AppProvider>(context, listen: false);

    // =========================================================================
    // 💡 PAYMENT GATEWAY HOOK:
    // When you are ready to integrate your live payment API (Stripe, Flutterwave,
    // Paystack, MTN MoMo API, or Orange Money API), replace this simulation block
    // with your HTTP request call.
    // =========================================================================
    await Future.delayed(const Duration(milliseconds: 1600));

    // Activate subscription in local provider & sync with backend database
    await provider.changeSubscriptionPlan(widget.plan);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161344) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Drag Handle & Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_open_rounded, color: AppColors.primaryCoral, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Activate ${widget.plan.title}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.mainText,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Checkout Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan Summary Banner Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1F1A54), const Color(0xFF131038)]
                              : [const Color(0xFFFFF0EC), const Color(0xFFFFF8F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.plan.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : AppColors.mainText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isYearlyBilling ? 'Yearly Billing (2 Months Free)' : 'Monthly Flexible Subscription',
                                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                              Text(
                                '$_amountInFCFA FCFA',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryCoral,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Monthly vs Yearly Switch
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isYearlyBilling = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: !_isYearlyBilling ? AppColors.primaryCoral : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: !_isYearlyBilling ? AppColors.primaryCoral : AppColors.cardBorder,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Monthly',
                                      style: TextStyle(
                                        color: !_isYearlyBilling ? Colors.white : AppColors.secondaryText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isYearlyBilling = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _isYearlyBilling ? AppColors.primaryCoral : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _isYearlyBilling ? AppColors.primaryCoral : AppColors.cardBorder,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Yearly (-20%)',
                                      style: TextStyle(
                                        color: _isYearlyBilling ? Colors.white : AppColors.secondaryText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Payment Method Header
                    Text(
                      'SELECT PAYMENT METHOD',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF9E9AC2) : AppColors.secondaryText,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Payment Methods Selector Row
                    Row(
                      children: [
                        _buildPaymentMethodOption(
                          type: PaymentMethodType.mobileMoney,
                          label: 'MoMo / Orange',
                          icon: Icons.phone_android_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildPaymentMethodOption(
                          type: PaymentMethodType.card,
                          label: 'Card (Visa/MC)',
                          icon: Icons.credit_card_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildPaymentMethodOption(
                          type: PaymentMethodType.appleGooglePay,
                          label: '1-Tap Pay',
                          icon: Icons.account_balance_wallet_rounded,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Conditional Form Fields based on Selected Payment Method
                    if (_selectedMethod == PaymentMethodType.mobileMoney) ...[
                      // Mobile Money Provider Selector
                      Text(
                        'Mobile Money Provider',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.mainText),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['MTN Mobile Money', 'Orange Money', 'Wave'].map((prov) {
                          final isSelected = _selectedMoMoProvider == prov;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedMoMoProvider = prov),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF231D5E) : const Color(0xFFFFECE8))
                                      : (isDark ? const Color(0xFF1B164C) : AppColors.background),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryCoral : AppColors.cardBorder,
                                    width: isSelected ? 1.8 : 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  prov.split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.primaryCoral : (isDark ? Colors.white70 : AppColors.mainText),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Phone Number Input
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.mainText),
                        decoration: InputDecoration(
                          labelText: 'Mobile Money Phone Number',
                          prefixIcon: const Icon(Icons.phone_rounded, size: 18),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1B164C) : AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '💡 A secure USSD prompt will be sent to your phone to confirm payment.',
                        style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                      ),
                    ] else if (_selectedMethod == PaymentMethodType.card) ...[
                      TextField(
                        controller: _cardHolderController,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.mainText),
                        decoration: InputDecoration(
                          labelText: 'Cardholder Name',
                          prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1B164C) : AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cardNumController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.mainText),
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          prefixIcon: const Icon(Icons.credit_card_rounded, size: 18),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1B164C) : AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cardExpiryController,
                              style: TextStyle(color: isDark ? Colors.white : AppColors.mainText),
                              decoration: InputDecoration(
                                labelText: 'MM/YY',
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1B164C) : AppColors.background,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _cardCvvController,
                              obscureText: true,
                              style: TextStyle(color: isDark ? Colors.white : AppColors.mainText),
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1B164C) : AppColors.background,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Apple Pay / Google Pay Instant Option
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B164C) : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.touch_app_rounded, size: 36, color: AppColors.primaryPurple),
                            SizedBox(height: 8),
                            Text(
                              'Instant 1-Tap Biometric Checkout',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Authenticate securely using Apple Pay or Google Pay tokenization.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Pay & Activate Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.coralGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppColors.glowShadow(AppColors.primaryCoral),
                        ),
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: _isProcessing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Contacting Payment Gateway...', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : Text(
                                  'Pay & Activate for $_amountInFCFA FCFA',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shield_outlined, size: 14, color: AppColors.secondaryText),
                          SizedBox(width: 4),
                          Text(
                            '256-Bit SSL Encrypted & Secure Payment Form',
                            style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required PaymentMethodType type,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedMethod == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF231D5E) : const Color(0xFFFFECE8))
                : (isDark ? const Color(0xFF1B164C) : AppColors.background),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryCoral : AppColors.cardBorder,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryCoral : AppColors.secondaryText, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primaryCoral : (isDark ? Colors.white70 : AppColors.mainText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
