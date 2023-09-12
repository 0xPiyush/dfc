import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { sent, received }

class LoanChatMessageModel {
  String id;
  String amountDepositedInPaise;
  String amountRemainingInPaise;
  Timestamp timestamp;
  TransactionType transactionType;

  LoanChatMessageModel({
    required this.id,
    required this.amountDepositedInPaise,
    required this.amountRemainingInPaise,
    required this.timestamp,
    required this.transactionType,
  });

  factory LoanChatMessageModel.fromJson(Map<String, dynamic> json) {
    return LoanChatMessageModel(
      id: json['id'],
      amountDepositedInPaise: json['amountInPaise'],
      amountRemainingInPaise: json['amountRemainingInPaise'],
      transactionType: json['transactionType'] == 'sent'
          ? TransactionType.sent
          : TransactionType.received,
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountInPaise': amountDepositedInPaise,
      'amountRemainingInPaise': amountRemainingInPaise,
      'transactionType':
          transactionType == TransactionType.sent ? 'sent' : 'received',
      'timestamp': timestamp,
    };
  }
}
