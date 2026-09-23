import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/ai_evaluator.dart';
import '../../models/subscription_plan.dart';
import '../../providers/app_provider.dart';
import '../subscription/payment_checkout_modal.dart';

class EvaluatorSelectorModal extends StatelessWidget {
  const EvaluatorSelectorModal({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CHOOSE YOUR AI EVALUATOR',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainText,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryCoral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Plan: ${provider.currentPlan.title}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryCoral,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Select a specialized AI coach tailored to your speaking goal.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: AIEvaluator.evaluators.length,
              itemBuilder: (context, index) {
                final evaluator = AIEvaluator.evaluators[index];
                final isSelected = provider.selectedEvaluator.id == evaluator.id;
                final isAllowed = provider.isEvaluatorAllowed(evaluator);
                final isPlusRequired = evaluator.id == 'thesis_jury' || evaluator.id == 'debate_opponent';

                return GestureDetector(
                  onTap: () {
                    if (isAllowed) {
                      provider.selectEvaluator(evaluator);
                      Navigator.pop(context);
                    } else {
                      final targetPlan = isPlusRequired ? SubscriptionPlan.plans[2] : SubscriptionPlan.plans[1];
                      PaymentCheckoutModal.show(context, targetPlan);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? evaluator.accentColor.withValues(alpha: 0.08)
                          : (isAllowed ? AppColors.background : const Color(0xFFF9F9FB)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? evaluator.accentColor
                            : (!isAllowed ? const Color(0xFFE2E0EE) : AppColors.cardBorder),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: evaluator.accentColor.withValues(alpha: isAllowed ? 0.15 : 0.06),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            evaluator.icon,
                            style: TextStyle(
                              fontSize: 22,
                              color: isAllowed ? null : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    evaluator.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isAllowed ? AppColors.mainText : Colors.grey.shade700,
                                    ),
                                  ),
                                  if (!isAllowed)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isPlusRequired
                                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                                            : AppColors.primaryCoral.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.lock_rounded,
                                            size: 10,
                                            color: isPlusRequired ? const Color(0xFF8B5CF6) : AppColors.primaryCoral,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            isPlusRequired ? 'PLUS ONLY' : 'PRO ONLY',
                                            style: TextStyle(
                                              color: isPlusRequired ? const Color(0xFF8B5CF6) : AppColors.primaryCoral,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: evaluator.accentColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        evaluator.title,
                                        style: TextStyle(
                                          color: evaluator.accentColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAllowed
                                    ? evaluator.description
                                    : 'Locked on Free Plan. Tap to activate ${isPlusRequired ? 'Executive Plus' : 'Pro Speaker'} & unlock.',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isAllowed ? AppColors.secondaryText : AppColors.primaryCoral,
                                  height: 1.3,
                                  fontWeight: isAllowed ? FontWeight.normal : FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: evaluator.accentColor,
                            size: 22,
                          )
                        else if (!isAllowed)
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.secondaryText,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
