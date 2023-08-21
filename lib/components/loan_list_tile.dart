import 'package:dfc/models/loan_model.dart';
import 'package:dfc/utils/utils.dart';
import 'package:flutter/material.dart';

class LoanListTile extends StatelessWidget {
  final LoanModel loanData;
  final void Function()? onTap;

  const LoanListTile({super.key, required this.loanData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          horizontalTitleGap: 0,
          leading: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on),
            ],
          ),
          title: Text(loanData.loanedToName),
          subtitle: Text(
            loanData.loanedOn.toLocal().toString().split(' ')[0],
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: RichText(
            text: TextSpan(
              text: "₹",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
              children: [
                TextSpan(
                  text: paiseToRupee(loanData.amount).toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                TextSpan(
                  text: " @${loanData.interestRate}%",
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
