import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dfc/models/loan_chat_message_model.dart';
import 'package:dfc/models/loan_model.dart';
import 'package:dfc/models/user_model.dart';
import 'package:dfc/services/auth.dart';
import 'package:dfc/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class LoanChatPage extends StatefulWidget {
  const LoanChatPage({super.key});

  @override
  State<LoanChatPage> createState() => _LoanChatPageState();
}

class _LoanChatPageState extends State<LoanChatPage> {
  var uuid = Uuid();

  Future<(List<LoanChatMessageModel>, String?)> fetchData(
      LoanModel loanData, bool showControls) async {
    String? avatarImageUrl;
    if (showControls) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(loanData.loanedToId)
          .get();

      if (snapshot.exists) {
        var fetchedUser =
            UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
        avatarImageUrl = fetchedUser.profileImage;
      }
    } else {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(loanData.loanedFromId)
          .get();

      if (snapshot.exists) {
        var fetchedUser =
            UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
        avatarImageUrl = fetchedUser.profileImage;
      }
    }

    return (
      List<LoanChatMessageModel>.from(loanData.messages!.reversed),
      avatarImageUrl
    );
  }

  var chatMessages = <types.Message>[];

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    final loanData = arguments['loanData'] as LoanModel;
    final showControls = arguments['showControls'] as bool;

    return FutureBuilder(
      future: fetchData(loanData, showControls),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text("Error fetching data"),
            ),
          );
        }

        if (snapshot.hasData) {
          var (List<LoanChatMessageModel> messages, String? avatarImageUrl) =
              snapshot.data!;

          var sender = types.User(
            id: loanData.loanedFromId,
            firstName: loanData.loanedFromName,
            imageUrl: avatarImageUrl,
            role: types.Role.user,
          );

          var receiver = types.User(
            id: loanData.loanedToId,
            firstName: loanData.loanedToName,
            imageUrl: userData!.profileImage,
            role: types.Role.user,
          );

          chatMessages = messages.map((message) {
            return types.TextMessage(
              author: message.transactionType == TransactionType.sent
                  ? receiver
                  : sender,
              text: paiseToRupee(message.amountDepositedInPaise).toString(),
              id: message.id,
              type: types.MessageType.text,
              createdAt: message.timestamp.millisecondsSinceEpoch,
              metadata: message.toJson(),
            );
          }).toList();

          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 80,
              titleSpacing: 0,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: avatarImageUrl != null
                          ? NetworkImage(avatarImageUrl)
                          : null,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(showControls
                          ? loanData.givenName
                          : loanData.loanedFromName),
                      const SizedBox(width: 10),
                      Text(
                        showControls
                            ? loanData.loanedToPhone
                            : loanData.loanedFromPhone,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                ],
              ),
              actions: showControls
                  ? [
                      IconButton(
                        onPressed: () {
                          // Show options menu
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                height: 300,
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.call),
                                      title:
                                          Text("Call ${loanData.loanedToName}"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        UrlLauncher.launchUrl(Uri.parse(
                                            "tel:${loanData.loanedToPhone}"));
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text("Delete Loan"),
                                      onTap: () async {
                                        await FirebaseFirestore.instance
                                            .collection('loans')
                                            .doc(loanData.loanId)
                                            .delete();

                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        showSnackBar(context, "Loan Deleted");
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ]
                  : null,
            ),
            body: Center(
              child: Chat(
                messages: chatMessages,
                onSendPressed: (t) {},
                user: showControls ? sender : receiver,
                bubbleBuilder: (child,
                    {required message, required nextMessageInGroup}) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message.metadata!["transactionType"],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Bubble(
                          borderWidth: 2,
                          borderColor:
                              message.metadata!["transactionType"] == "sent"
                                  ? Colors.red
                                  : Colors.green,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (message.metadata!["transactionType"] ==
                                  "sent")
                                const Icon(
                                  Icons.arrow_circle_up_outlined,
                                  color: Colors.red,
                                )
                              else
                                const Icon(
                                  Icons.arrow_circle_down_outlined,
                                  color: Colors.green,
                                ),
                              const SizedBox(width: 10),
                              Text(
                                "₹${paiseToRupee(message.metadata!["amountInPaise"]).toString()}",
                                style: Theme.of(context).textTheme.bodyLarge,
                              )
                            ],
                          ),
                        ),
                        Text(
                          "Remaining: ₹${paiseToRupee(message.metadata!["amountRemainingInPaise"])}"
                              .toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
                customBottomWidget: showControls
                    ? Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    var formKey = GlobalKey<FormState>();

                                    var amountController =
                                        TextEditingController();
                                    return AlertDialog(
                                      title: const Text("Add Payment"),
                                      content: Form(
                                        key: formKey,
                                        child: TextFormField(
                                          controller: amountController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                // await addPayment(
                                                //   loans[index]
                                                //       .loanId!,
                                                //   loans[index]
                                                //       .amountPaid,
                                                //   amountController
                                                //       .text,
                                                // );
                                                await addSent(
                                                    amountController.text,
                                                    loanData,
                                                    sender);
                                                if (mounted) {
                                                  Navigator.pop(context);
                                                  showSnackBar(
                                                      context, "Loan Updated");
                                                }
                                                setState(() {});
                                              }
                                            },
                                            child: const Text(
                                              "Add Sent",
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
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(140, 50),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.arrow_circle_up_outlined),
                                  SizedBox(width: 10),
                                  Text("Sent")
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    var formKey = GlobalKey<FormState>();

                                    var amountController =
                                        TextEditingController();
                                    return AlertDialog(
                                      title: const Text("Add Payment"),
                                      content: Form(
                                        key: formKey,
                                        child: TextFormField(
                                          controller: amountController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                // await addPayment(
                                                //   loans[index]
                                                //       .loanId!,
                                                //   loans[index]
                                                //       .amountPaid,
                                                //   amountController
                                                //       .text,
                                                // );
                                                await addRecevied(
                                                    amountController.text,
                                                    loanData,
                                                    receiver);
                                                if (mounted) {
                                                  Navigator.pop(context);
                                                  showSnackBar(
                                                      context, "Loan Updated");
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
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(140, 50),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.arrow_circle_down_outlined),
                                  SizedBox(width: 10),
                                  Text("Received")
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text("Error fetching data"),
            ),
          );
        }
      },
    );
  }

  Future<void> addRecevied(
      String amount, LoanModel loanData, types.User user) async {
    var newAmountPaid =
        BigInt.parse(loanData.amountPaid) + rupeeToPaise(amount);

    var message = LoanChatMessageModel(
      id: uuid.v4(),
      amountDepositedInPaise: rupeeToPaise(amount).toString(),
      amountRemainingInPaise:
          "${BigInt.parse(loanData.amount) - newAmountPaid}",
      transactionType: TransactionType.received,
      timestamp: Timestamp.now(),
    );

    await FirebaseFirestore.instance
        .collection('loans')
        .doc(loanData.loanId)
        .update({
      'amountPaid': newAmountPaid.toString(),
      'messages': FieldValue.arrayUnion([message.toJson()])
    });

    setState(() {
      chatMessages.insert(
          0,
          types.TextMessage(
            author: user,
            text: paiseToRupee(message.amountDepositedInPaise).toString(),
            id: message.id,
            type: types.MessageType.text,
            createdAt: message.timestamp.millisecondsSinceEpoch,
            metadata: message.toJson(),
          ));
    });
  }

  Future<void> addSent(
      String amount, LoanModel loanData, types.User user) async {
    var newLoanedAmount = BigInt.parse(loanData.amount) + rupeeToPaise(amount);

    var message = LoanChatMessageModel(
      id: uuid.v4(),
      amountDepositedInPaise: rupeeToPaise(amount).toString(),
      amountRemainingInPaise:
          "${newLoanedAmount - BigInt.parse(loanData.amountPaid)}",
      transactionType: TransactionType.sent,
      timestamp: Timestamp.now(),
    );

    await FirebaseFirestore.instance
        .collection('loans')
        .doc(loanData.loanId)
        .update({
      'amount': newLoanedAmount.toString(),
      'messages': FieldValue.arrayUnion([message.toJson()])
    });

    setState(() {
      chatMessages.insert(
          0,
          types.TextMessage(
            author: user,
            text: paiseToRupee(message.amountDepositedInPaise).toString(),
            id: message.id,
            type: types.MessageType.text,
            createdAt: message.timestamp.millisecondsSinceEpoch,
            metadata: message.toJson(),
          ));
    });
  }
}
