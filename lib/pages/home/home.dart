import 'package:dfc/pages/app_routes.dart';
import 'package:dfc/pages/due_payments/due_payments.dart';
import 'package:dfc/pages/given_loans/given_loans.dart';
import 'package:dfc/services/auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, Widget> _tabs = {
    DuePaymentsPage.pageTitle: const DuePaymentsPage(),
    GivenLoansPage.pageTitle: const GivenLoansPage(),
  };
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tabs.keys.toList()[_currentIndex],
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.profile.route);
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: CircleAvatar(
                  radius: 23,
                  backgroundImage: NetworkImage(
                    userData!.profileImage,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _tabs.values.toList()[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: "Due Payments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Given Loans",
          ),
        ],
      ),
    );
  }
}
