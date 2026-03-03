import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/job_completion_controller.dart';
import 'completion/step1_job_summary.dart';
import 'completion/step2_payment.dart';
import 'completion/step3_rating.dart';
import 'completion/step4_completion_success.dart';

class JobCompletionPage extends StatelessWidget {
  const JobCompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<JobCompletionController>();

    // Init job data from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && c.jobData.value == null) {
      c.initJob(args['job'], args['jobId']);
    }

    return WillPopScope(
      onWillPop: () async {
        if (c.currentStep.value > 0 && c.currentStep.value < 3) {
          c.prevStep();
          return false;
        }
        return c.currentStep.value == 0; // Only allow back on step 0
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Obx(() => _buildAppBar(c)),
        ),
        body: Obx(() {
          switch (c.currentStep.value) {
            case 0:
              return const JobSummaryView();
            case 1:
              return const PaymentView();
            case 2:
              return const RatingView();
            case 3:
              return const CompletionSuccessView();
            default:
              return const JobSummaryView();
          }
        }),
      ),
    );
  }

  Widget _buildAppBar(JobCompletionController c) {
    final isSuccess = c.currentStep.value == 3;
    final step = c.currentStep.value;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(Get.context!).padding.top),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (!isSuccess)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () {
                      if (step > 0) {
                        c.prevStep();
                      } else {
                        Get.back();
                      }
                    },
                  )
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    isSuccess ? 'Completed!' : _stepTitle(step),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Progress Bar
          if (!isSuccess)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: List.generate(3, (i) {
                  final active = i <= step;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return 'Job Summary';
      case 1:
        return 'Payment';
      case 2:
        return 'Rate Customer';
      default:
        return '';
    }
  }
}
