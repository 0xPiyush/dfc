enum LoanType { compound, simple }

class LoanModel {
  final String id;
  final String loanedTo;
  final String loanedFrom;
  final BigInt amount; // in Paise 1 Rupee = 100 Paise
  final DateTime loanedOn;
  final DateTime loanedUntil;
  final LoanType loanType;
  final double interestRate;
  final String description;
  final bool isPaid;

  LoanModel(
      this.id,
      this.loanedTo,
      this.loanedFrom,
      this.amount,
      this.loanedOn,
      this.loanedUntil,
      this.loanType,
      this.interestRate,
      this.description,
      this.isPaid);

  factory LoanModel.fromMap(Map<String, dynamic> json) {
    return LoanModel(
      json['id'],
      json['loanedTo'],
      json['loanedFrom'],
      json['amount'],
      DateTime.parse(json['loanedOn']),
      DateTime.parse(json['loanedUntil']),
      json['loanType'] == 'compound' ? LoanType.compound : LoanType.simple,
      json['interestRate'],
      json['description'],
      json['isPaid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loanedTo': loanedTo,
      'loanedFrom': loanedFrom,
      'amount': amount,
      'loanedOn': loanedOn.toIso8601String(),
      'loanedUntil': loanedUntil.toIso8601String(),
      'loanType': loanType == LoanType.compound ? 'compound' : 'simple',
      'interestRate': interestRate,
      'description': description,
      'isPaid': isPaid,
    };
  }
}
