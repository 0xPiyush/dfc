import 'package:dfc/components/loan_list_tile.dart';
import 'package:dfc/models/loan_model.dart';
import 'package:dfc/pages/app_routes.dart';
import 'package:flutter/material.dart';

class GivenLoansPage extends StatefulWidget {
  const GivenLoansPage({super.key});
  static const String pageTitle = "Loans";

  @override
  State<GivenLoansPage> createState() => _GivenLoansPageState();
}

class _GivenLoansPageState extends State<GivenLoansPage> {
  @override
  Widget build(BuildContext context) {
    // return floating action button on bottom right
    return Scaffold(
        body: Center(
          child: ListView(
            children: <Widget>[
              LoanListTile(
                loanData: LoanModel(
                  "test id",
                  "Test User",
                  "Test Loan Giver User",
                  BigInt.parse("12345"),
                  DateTime.now(),
                  DateTime.now(),
                  LoanType.simple,
                  10,
                  "Test description",
                  false,
                ),
              ),
              LoanListTile(
                loanData: LoanModel(
                  "test id",
                  "Test User",
                  "Test Loan Giver User",
                  BigInt.parse("12345"),
                  DateTime.now(),
                  DateTime.now(),
                  LoanType.simple,
                  10,
                  "Test description",
                  false,
                ),
              ),
            ],
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
}
