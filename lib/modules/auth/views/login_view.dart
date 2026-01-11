import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final AuthController controller = Get.find();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final RxBool isOtpSent = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "DriveResQ",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // 📱 Phone Number Input
              if (!isOtpSent.value)
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    hintText: "+91XXXXXXXXXX",
                    border: OutlineInputBorder(),
                  ),
                ),

              // 🔐 OTP Input
              if (isOtpSent.value) ...[
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Enter OTP",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ⏳ Loader or Button
              controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        if (!isOtpSent.value) {
                          // SEND OTP
                          String phone = phoneController.text.trim();
                          if (phone.isEmpty) {
                            Get.snackbar("Error", "Enter phone number");
                            return;
                          }
                          controller.sendOtp(phone);
                          isOtpSent.value = true;
                        } else {
                          // VERIFY OTP
                          String otp = otpController.text.trim();
                          if (otp.length != 6) {
                            Get.snackbar("Error", "Enter valid OTP");
                            return;
                          }
                          controller.verifyOtp(otp);
                        }
                      },
                      child: Text(
                        isOtpSent.value ? "Verify OTP" : "Send OTP",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

              const SizedBox(height: 10),

              // 🔁 Resend OTP
              if (isOtpSent.value)
                TextButton(
                  onPressed: () {
                    isOtpSent.value = false;
                    otpController.clear();
                  },
                  child: const Text("Change Phone Number"),
                ),
            ],
          );
        }),
      ),
    );
  }
}
