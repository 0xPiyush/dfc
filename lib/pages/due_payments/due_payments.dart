import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dfc/components/loan_list_tile.dart';
import 'package:dfc/models/loan_model.dart';
import 'package:dfc/pages/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DuePaymentsPage extends StatefulWidget {
  const DuePaymentsPage({super.key});
  static const String pageTitle = "Payments";

  @override
  State<DuePaymentsPage> createState() => _DuePaymentsPageState();
}

class _DuePaymentsPageState extends State<DuePaymentsPage> {
  Future<List<LoanModel>?> getDuePayments() async {
    var doc = await FirebaseFirestore.instance
        .collection('loans')
        .where('loanedToId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
          future: getDuePayments(),
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
                              child: Text("No Due Payments."),
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
                            Navigator.pushNamed(
                              context,
                              AppRoutes.loanChat.route,
                              arguments: {
                                'loanData': loans[index],
                                'showControls': false,
                              },
                            );
                            // var totalAmount = paiseToRupee(loans[index].amount);
                            // showDialog(
                            //     context: context,
                            //     builder: (BuildContext context) {
                            //       return AlertDialog(
                            //         title: Text(loans[index].givenName),
                            //         content: Text(
                            //           "Amount: ₹${paiseToRupee(loans[index].amount).toString()}\n"
                            //           "Total Amount: ₹$totalAmount\n"
                            //           "Amount Paid: ₹${paiseToRupee(loans[index].amountPaid)}\n"
                            //           "Remaining Amount: ₹${totalAmount - paiseToRupee(loans[index].amountPaid)}\n"
                            //           "Loaned On: ${loans[index].loanedOn.toLocal().toString().split(' ')[0]}\n"
                            //           "Loaned Until: ${loans[index].loanedUntil.toLocal().toString().split(' ')[0]}\n",
                            //         ),
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(10),
                            //         ),
                            //         actionsAlignment:
                            //             MainAxisAlignment.spaceEvenly,
                            //         actions: [
                            //           TextButton(
                            //             onPressed: () {
                            //               Navigator.pop(context);
                            //             },
                            //             child: const Text("Close"),
                            //           ),
                            //         ],
                            //       );
                            //     });
                          },
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
