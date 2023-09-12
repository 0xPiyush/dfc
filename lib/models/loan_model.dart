import 'package:dfc/models/loan_chat_message_model.dart';

class LoanModel {
  final String? loanId;
  final String loanedToId;
  final String loanedToName;
  final String givenName;
  final String loanedToPhone;
  final String loanedFromId;
  final String loanedFromName;
  final String loanedFromPhone;
  final String amount; // in Paise 1 Rupee = 100 Paise
  final String amountPaid;
  final DateTime loanedOn;
  final DateTime loanedUntil;
  final String description;
  final bool isPaid;
  final List<LoanChatMessageModel>? messages;

  LoanModel({
    this.loanId,
    required this.loanedToId,
    required this.loanedToName,
    required this.givenName,
    required this.loanedToPhone,
    required this.loanedFromId,
    required this.loanedFromName,
    required this.loanedFromPhone,
    required this.amount,
    required this.amountPaid,
    required this.loanedOn,
    required this.loanedUntil,
    required this.description,
    required this.isPaid,
    this.messages,
  });

  factory LoanModel.fromMap(Map<String, dynamic> json) {
    var messages = (json['messages'] as List<dynamic>)
        .map((message) => LoanChatMessageModel.fromJson(message))
        .toList();
    return LoanModel(
      loanId: json['loanId'],
      loanedToId: json['loanedToId'],
      loanedToName: json['loanedToName'],
      givenName: json['givenName'],
      loanedToPhone: json['loanedToPhone'],
      loanedFromId: json['loanedFromId'],
      loanedFromName: json['loanedFromName'],
      loanedFromPhone: json['loanedFromPhone'],
      amount: json['amount'],
      amountPaid: json['amountPaid'],
      loanedOn: DateTime.parse(json['loanedOn']),
      loanedUntil: DateTime.parse(json['loanedUntil']),
      description: json['description'],
      isPaid: json['isPaid'],
      messages: messages,
    );
  }

  Map<String, dynamic> toMap() {
    var m = messages?.map((message) => message.toJson()).toList();
    return {
      'loanedToId': loanedToId,
      'loanedToName': loanedToName,
      'givenName': givenName,
      'loanedToPhone': loanedToPhone,
      'loanedFromId': loanedFromId,
      'loanedFromName': loanedFromName,
      'loanedFromPhone': loanedFromPhone,
      'amount': amount,
      'amountPaid': amountPaid,
      'loanedOn': loanedOn.toIso8601String(),
      'loanedUntil': loanedUntil.toIso8601String(),
      'description': description,
      'isPaid': isPaid,
      'messages': m,
    };
  }
}
