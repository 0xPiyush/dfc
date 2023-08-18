import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dfc/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

UserModel? userData;

sendOtp(String phone, Function afterSent) async {
  try {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception(e.message);
      },
      codeSent: (verificationId, forceResendingToken) {
        afterSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<bool> verifyOtp(
    BuildContext context, String verificationId, String otp) async {
  try {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);

    return true;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

Future<bool> checkUserOnboardingFinished(User user) async {
  await fetchUserData();
  if (userData != null) {
    return true;
  } else {
    return false;
  }
}

Future<void> fetchUserData() async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  if (snapshot.exists) {
    userData = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
  }
}

Future<void> saveUserDataToFirebase(
    String name, String email, File profileImage) async {
  try {
    // Upload profile image to firebase storage
    String url = await storeFileToFirebase(
        'profile_images/${FirebaseAuth.instance.currentUser!.uid}',
        profileImage);
    UserModel user = UserModel(
      uid: FirebaseAuth.instance.currentUser!.uid,
      name: name,
      email: email,
      phone: FirebaseAuth.instance.currentUser!.phoneNumber!,
      profileImage: url,
      createdAt: DateTime.now().toString(),
    );

    // Save user data to firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(user.toMap());

    // Update local user data
    await fetchUserData();
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<String> storeFileToFirebase(String ref, File profileImage) async {
  UploadTask uploadTask =
      FirebaseStorage.instance.ref().child(ref).putFile(profileImage);
  TaskSnapshot snapshot = await uploadTask;
  return await snapshot.ref.getDownloadURL();
}
