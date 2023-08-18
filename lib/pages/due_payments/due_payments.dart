import 'package:flutter/widgets.dart';

class DuePaymentsPage extends StatefulWidget {
  const DuePaymentsPage({super.key});
  static const String pageTitle = "Payments";

  @override
  State<DuePaymentsPage> createState() => _DuePaymentsPageState();
}

class _DuePaymentsPageState extends State<DuePaymentsPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('DuePaymentsPage'),
    );
  }
}
