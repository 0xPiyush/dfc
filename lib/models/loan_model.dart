enum InterestType { compound, simple }

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
  final InterestType interestType;
  final double interestRate;
  final String description;
  final bool isPaid;

  LoanModel(
      {this.loanId,
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
      required this.interestType,
      required this.interestRate,
      required this.description,
      required this.isPaid});

  factory LoanModel.fromMap(Map<String, dynamic> json) {
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
      interestType: json['loanType'] == 'compound'
          ? InterestType.compound
          : InterestType.simple,
      interestRate: json['interestRate'],
      description: json['description'],
      isPaid: json['isPaid'],
    );
  }

  Map<String, dynamic> toMap() {
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
      'loanType': interestType == InterestType.compound ? 'compound' : 'simple',
      'interestRate': interestRate,
      'description': description,
      'isPaid': isPaid,
    };
  }
}
