import 'package:dfc/pages/app_routes.dart';
import 'package:dfc/services/auth.dart';
import 'package:dfc/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

class OtpVerifyPage extends StatefulWidget {
  final String verificationId;
  const OtpVerifyPage({super.key, required this.verificationId});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 32),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 100),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 160,
                            width: 160,
                            child: Image.asset(
                                "assets/images/dfc_logo_transparent.png"),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Verification",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Enter the OTP sent to your phone number.",
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Pinput(
                            autofocus: true,
                            length: 6,
                            showCursor: true,
                            defaultPinTheme: PinTheme(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              textStyle: Theme.of(context).textTheme.bodyLarge,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length < 6) {
                                return 'Please enter the OTP';
                              }
                              return null;
                            },
                            pinputAutovalidateMode:
                                PinputAutovalidateMode.onSubmit,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6)
                            ],
                            onCompleted: (value) async {
                              try {
                                setState(() {
                                  _isLoading = true;
                                });
                                bool verified = await verifyOtp(
                                    context, widget.verificationId, value);
                                setState(() {
                                  _isLoading = false;
                                });
                                if (verified) {
                                  // Check if user has completed onboarding
                                  // Delay for 1 second to allow the user to see the OTP verification success message
                                  if (mounted) {
                                    showSnackBar(context, 'OTP verified');
                                  }
                                  await Future.delayed(
                                      const Duration(seconds: 1));
                                  bool finished =
                                      await checkUserOnboardingFinished(
                                          FirebaseAuth.instance.currentUser!);
                                  if (mounted) {
                                    if (finished) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        AppRoutes.home.route,
                                        (route) => false,
                                      );
                                    } else {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        AppRoutes.onboarding.route,
                                        (route) => false,
                                      );
                                    }
                                  }
                                } else {
                                  if (mounted) {
                                    showSnackBar(context, 'Invalid OTP');
                                  }
                                }
                              } catch (e) {
                                showSnackBar(context, e.toString());
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Resend OTP'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
