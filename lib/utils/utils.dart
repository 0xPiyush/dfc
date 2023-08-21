import 'dart:io';

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

BigInt paiseToRupee(String paise) {
  return BigInt.from(double.parse(paise) / 100);
}
