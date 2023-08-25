import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dfc/models/loan_model.dart';
import 'package:dfc/services/auth.dart';
import 'package:dfc/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewLoanPage extends StatefulWidget {
  const NewLoanPage({super.key});

  @override
  State<NewLoanPage> createState() => _NewLoanPageState();
}

class _NewLoanPageState extends State<NewLoanPage> {
  DateTime? loanedUntilDate = DateTime.now().add(const Duration(days: 1));
  var phoneController = TextEditingController();
  Country selectedCountry = CountryService().findByCode('IN')!;
  var amountController = TextEditingController();
  var interestRateController = TextEditingController();
  var interestType = InterestType.simple;
  var descriptionController = TextEditingController();

  var _isLoading = false;
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        title: Text(
          "New Loan",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        centerTitle: true,
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        "Loaned to:",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
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
                                      textStyle:
                                          Theme.of(context).textTheme.bodySmall,
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
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        "Loan Amount:",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Amount loaned",
                          hintText: "Amount loaned",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10)
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the amount loaned';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        "Loaned Until:",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: loanedUntilDate!,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 10),
                              ),
                            ).then((value) {
                              setState(() {
                                if (value != null) {
                                  loanedUntilDate = value;
                                }
                              });
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loanedUntilDate.toString().split(" ")[0],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(Icons.edit),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        "Interest Rate (%):",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Interest Rate (%)",
                          hintText: "Interest Rate (%)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: interestRateController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2)
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the interest rate';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Interest Type:",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RadioListTile(
                        title: const Text("Simple Interest"),
                        value: InterestType.simple,
                        groupValue: interestType,
                        onChanged: (value) {
                          setState(() {
                            interestType = value!;
                          });
                        },
                      ),
                      RadioListTile(
                        title: const Text("Compound Interest"),
                        value: InterestType.compound,
                        groupValue: interestType,
                        onChanged: (value) {
                          setState(() {
                            interestType = value!;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        "Description:",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: descriptionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1000),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              var phoneNumber =
                                  '+${selectedCountry.phoneCode}${phoneController.text}';
                              var loanedToUser =
                                  await phoneNumberExists(phoneNumber);

                              if (loanedToUser == null) {
                                setState(() {
                                  _isLoading = false;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Phone number not found",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .fontSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                }
                                return;
                              }
                              var loan = LoanModel(
                                loanedToId: loanedToUser.docs[0]["uid"],
                                loanedToName: loanedToUser.docs[0]["name"],
                                loanedToPhone: loanedToUser.docs[0]["phone"],
                                loanedFromId:
                                    FirebaseAuth.instance.currentUser!.uid,
                                loanedFromName: userData!.name,
                                loanedFromPhone: userData!.phone,
                                amount: rupeeToPaise(amountController.text)
                                    .toString(),
                                amountPaid: "0",
                                loanedOn: DateTime.now(),
                                loanedUntil: loanedUntilDate!,
                                interestType: interestType,
                                interestRate:
                                    double.parse(interestRateController.text),
                                description: descriptionController.text,
                                isPaid: false,
                              );
                              await FirebaseFirestore.instance
                                  .collection("loans")
                                  .add(loan.toMap());

                              setState(() {
                                _isLoading = false;
                              });
                              if (mounted) {
                                showSnackBar(context, "Loan created");
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8),
                            child: Text(
                              "Create",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> phoneNumberExists(
      String phoneNumber) async {
    // Check firestore for phone number
    var doc = FirebaseFirestore.instance.collection("users").where(
          "phone",
          isEqualTo: phoneNumber,
        );
    var docSnap = await doc.get();
    if (docSnap.docs.isNotEmpty) {
      return docSnap;
    }
    return null;
  }
}
