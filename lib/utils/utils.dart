import 'dart:io';
import 'dart:math';

import 'package:dfc/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

Future<File?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
      source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);

  if (image != null) {
    return File(image.path);
  } else {
    return null;
  }
}

BigInt rupeeToPaise(String rupee) {
  return BigInt.from(double.parse(rupee) * 100);
}

double paiseToRupee(String paise) {
  return double.parse(paise) / 100;
}

BigInt compoundInterest(BigInt principal, double rate, int days) {
  return BigInt.from(
      (principal.toDouble() * pow(1 + ((rate / 100) / 12), (days / 365) * 12) -
              principal.toDouble())
          .round());
}

BigInt simpleInterest(BigInt principal, double rate, int days) {
  return BigInt.from(
      (principal.toDouble() * (rate / 100) * (days / 365)).round());
}

BigInt calculateInterest(BigInt principal, double rate, int days,
    {InterestType interestType = InterestType.simple}) {
  if (interestType == InterestType.compound) {
    return compoundInterest(principal, rate, days);
  } else {
    return simpleInterest(principal, rate, days);
  }
}

int daysBetween(DateTime from, DateTime to) {
  return to.difference(from).inDays + 1;
}

int daysToYears(int days) {
  return (days / 365).floor();
}
