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
                                      "Interest Rate: ${loans[index].interestRate}%\n"
                                      "Interest Type: ${loans[index].interestType == InterestType.simple ? "Simple" : "Compounding"}\n"
                                      "Loaned On: ${loans[index].loanedOn.toLocal().toString().split(' ')[0]}\n"
                                      "Loaned Until: ${loans[index].loanedUntil.toLocal().toString().split(' ')[0]}\n"
                                      "Status: ${loans[index].isPaid ? "Paid" : "Not Paid"}",
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    actionsAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    actions: [
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
}
