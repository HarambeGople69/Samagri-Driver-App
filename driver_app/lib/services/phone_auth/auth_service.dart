import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

import '../../controller/dashboard_controller.dart';
import '../../db/db_helper.dart';
import '../../widget/our_flutter_toast.dart';
import '../firestore_service/driver_profile_detail_services.dart';

class GoogleAuth {
  signIn(BuildContext context) async {
    print("Inside google sign in");
    print("===============");
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      OAuthCredential credential = await GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value) async {
        print("Utsav Shrestha");
        print(googleUser!.displayName);
        print(googleUser.email);
        print(googleUser.photoUrl);
        print(googleUser.id);
        await DriverProfileDetailService().initializeUser(
          googleUser.displayName ?? "",
          googleUser.email,
          googleUser.photoUrl ?? "",
        );
        Hive.box<int>(DatabaseHelper.outerlayerDB).put(
          "state",
          2,
        );
        // OnceOnboarding().googlelogin();
        OurToast().showSuccessToast("Welcome, ${googleUser.displayName}");
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        //   return DashBoard();
        // }));
      });
    } on FirebaseAuthException catch (e) {
      OurToast().showErrorToast(e.message!);
    }
  }

  logout(BuildContext context) async {
    try {
      // await FirebaseAuth.instance.signOut();
      await FirebaseFirestore.instance
          .collection("Drivers")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        "token": "",
      });
      await GoogleSignIn().disconnect();
      await GoogleSignIn().signOut().then((value) async {
        // OnceOnboarding().googlelogout();
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        //   return LoginPage();
        // }));
        Get.find<DashboardController>().changeIndexs(0);
        await Hive.box<int>(DatabaseHelper.outerlayerDB).put("state", 1);
      });
    } on FirebaseAuthException catch (e) {
      OurToast().showErrorToast("Error occured");
    }
  }
}
