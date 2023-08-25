import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dfc/components/loan_list_tile.dart';
import 'package:dfc/models/loan_model.dart';
import 'package:dfc/pages/app_routes.dart';
import 'package:dfc/utils/utils.dart';

import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GivenLoansPage extends StatefulWidget {
  const GivenLoansPage({super.key});
  static const String pageTitle = "Loans";

  @override
  State<GivenLoansPage> createState() => _GivenLoansPageState();
}

class _GivenLoansPageState extends State<GivenLoansPage> {
  Future<List<LoanModel>?> getGivenLoans() async {
    var doc = await FirebaseFirestore.instance
        .collection('loans')
        .where('loanedFromId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (doc.docs.isNotEmpty) {
      var data = doc.docs.map((e) {
        var loanData = e.data();
        loanData["loanId"] = e.id;
        return LoanModel.fromMap(loanData);
      }).toList();
      data.sort((a, b) => b.loanedOn.compareTo(a.loanedOn));
      return data;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // return floating action button on bottom right
    return Scaffold(
        body: Center(
          child: FutureBuilder(
            future: getGivenLoans(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              final List<LoanModel> loans = snapshot.data ?? [];
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: loans.isEmpty
                    ? const Center(
                        child: CustomScrollView(
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Text("No Loans Given."),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: loans.length,
                        itemBuilder: (context, index) {
                          return LoanListTile(
                            loanData: loans[index],
                            onTap: () {
                              var totalInterest = paiseToRupee(
                                  calculateInterest(
                                          BigInt.parse(loans[index].amount),
                                          loans[index].interestRate,
                                          daysBetween(loans[index].loanedOn,
                                              loans[index].loanedUntil),
                                          interestType:
                                              loans[index].interestType)
                                      .toString());
                              var totalAmount =
                                  paiseToRupee(loans[index].amount) +
                                      totalInterest;

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(loans[index].loanedToName),
                                        IconButton(
                                          onPressed: () {
                                            UrlLauncher.launchUrl(Uri.parse(
                                                "tel:${loans[index].loanedToPhone}"));
                                          },
                                          icon: const Icon(Icons.call),
                                        )
                                      ],
                                    ),
                                    content: Text(
                                      "Amount: ₹${paiseToRupee(loans[index].amount).toString()}\n"
                                      "Total Amount: ₹$totalAmount\n"
                                      "Interest Rate: ${loans[index].interestRate}%\n"
                                      "Interest Type: ${loans[index].interestType == InterestType.simple ? "Simple" : "Compounding"}\n"
                                      "Total Interest: ₹$totalInterest\n"
                                      "Amount Paid: ₹${paiseToRupee(loans[index].amountPaid)}\n"
                                      "Remaining Amount: ₹${totalAmount - paiseToRupee(loans[index].amountPaid)}\n"
                                      "Loaned On: ${loans[index].loanedOn.toLocal().toString().split(' ')[0]}\n"
                                      "Loaned Until: ${loans[index].loanedUntil.toLocal().toString().split(' ')[0]}\n",
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    actionsAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                var formKey =
                                                    GlobalKey<FormState>();

                                                var amountController =
                                                    TextEditingController();
                                                return AlertDialog(
                                                  title:
                                                      const Text("Add Payment"),
                                                  content: Form(
                                                    key: formKey,
                                                    child: TextFormField(
                                                      controller:
                                                          amountController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText: "Amount",
                                                      ),
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return "Please enter amount";
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  actionsAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () async {
                                                          if (formKey
                                                              .currentState!
                                                              .validate()) {
                                                            await addPayment(
                                                              loans[index]
                                                                  .loanId!,
                                                              loans[index]
                                                                  .amountPaid,
                                                              amountController
                                                                  .text,
                                                            );
                                                            if (mounted) {
                                                              Navigator.pop(
                                                                  context);
                                                              showSnackBar(
                                                                  context,
                                                                  "Loan Updated");
                                                            }
                                                            setState(() {});
                                                          }
                                                        },
                                                        child: const Text(
                                                          "Add Payment",
                                                        )),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        child: const Text("Add Payment"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await deleteLoan(
                                              loans[index].loanId!);
                                          if (mounted) {
                                            Navigator.pop(context);
                                            showSnackBar(
                                                context, "Loan Deleted");
                                          }
                                          setState(() {});
                                        },
                                        child: const Text("Delete"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.newLoan.route);
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add),
        ));
  }

  Future<void> deleteLoan(String loanId) async {
    await FirebaseFirestore.instance.collection('loans').doc(loanId).delete();
  }

  Future<void> addPayment(
      String loanId, String amountPaid, String amount) async {
    var newAmountPaid = BigInt.parse(amountPaid) + rupeeToPaise(amount);

    await FirebaseFirestore.instance
        .collection('loans')
        .doc(loanId)
        .update({'amountPaid': newAmountPaid.toString()});
  }
}
