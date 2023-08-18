import 'package:dfc/models/loan_model.dart';
import 'package:flutter/material.dart';

class LoanListTile extends StatelessWidget {
  final LoanModel loanData;

  const LoanListTile({super.key, required this.loanData});

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
          title: Text(loanData.loanedTo),
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
                  text: (loanData.amount / BigInt.parse("100")).toString(),
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
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loanData.loanedTo),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.call),
                        )
                      ],
                    ),
                    content: Text(
                      "Amount: ₹${(loanData.amount / BigInt.parse("100")).toString()}\n"
                      "Interest Rate: ${loanData.interestRate}%\n"
                      "Interest Type: ${loanData.loanType == LoanType.simple ? "Simple" : "Compounding"}\n"
                      "Loaned On: ${loanData.loanedOn.toLocal().toString().split(' ')[0]}\n"
                      "Loaned Until: ${loanData.loanedUntil.toLocal().toString().split(' ')[0]}\n"
                      "Status: ${loanData.isPaid ? "Paid" : "Not Paid"}",
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Edit"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Mark Paid"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                });
          },
        ),
      ),
    );
  }
}
