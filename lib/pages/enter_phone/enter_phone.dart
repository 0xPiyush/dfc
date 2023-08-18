import 'package:country_picker/country_picker.dart';
import 'package:dfc/pages/otp_verify/otp_verify.dart';
import 'package:dfc/services/auth.dart';
import 'package:dfc/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnterPhonePage extends StatefulWidget {
  const EnterPhonePage({super.key});

  @override
  State<EnterPhonePage> createState() => _EnterPhonePageState();
}

class _EnterPhonePageState extends State<EnterPhonePage> {
  var formKey = GlobalKey<FormState>();

  final phoneController = TextEditingController();

  Country selectedCountry = CountryService().findByCode('IN')!;

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
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 100),
                  child: Form(
                    key: formKey,
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
                          "Phone Number",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter your phone number to get started.",
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Phone number',
                            prefixIcon: InkWell(
                                onTap: () {
                                  showCountryPicker(
                                      context: context,
                                      countryListTheme: CountryListThemeData(
                                        borderRadius: BorderRadius.circular(8),
                                        bottomSheetHeight: 400,
                                        inputDecoration: InputDecoration(
                                          labelText: 'Search',
                                          hintText: 'Start typing to search',
                                          prefixIcon: const Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade400,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      onSelect: (country) {
                                        setState(() {
                                          selectedCountry = country;
                                        });
                                      });
                                },
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  runAlignment: WrapAlignment.center,
                                  children: [
                                    const SizedBox(width: 8),
                                    Text(
                                      "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                )),
                          ),
                          keyboardType: TextInputType.number,
                          autocorrect: false,
                          controller: phoneController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 10) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                setState(() {
                                  _isLoading = true;
                                });
                                sendOtp(
                                    "+${selectedCountry.phoneCode}${phoneController.text}",
                                    (verificationId) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  // appRouter.push(AppRoutes.otpVerify.route, extra: verificationId);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return OtpVerifyPage(
                                            verificationId: verificationId);
                                      },
                                    ),
                                  );
                                });
                              } catch (e) {
                                showSnackBar(context, e.toString());
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 42),
                          ),
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
