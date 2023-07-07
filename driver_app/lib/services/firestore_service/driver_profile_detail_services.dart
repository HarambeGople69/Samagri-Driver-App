import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DriverProfileDetailService {
  var firestore = FirebaseFirestore.instance;

  initializeUser(String name, String email, String photoUrl) async {
    try {
      final QuerySnapshot resultQuery = await firestore
          .collection("Driver")
          .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;

      String? token = await FirebaseMessaging.instance.getToken();
      if (documentSnapshots.isEmpty) {
        print("=================== First Time =================");

        await FirebaseFirestore.instance
            .collection("Drivers")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          "uid": FirebaseAuth.instance.currentUser!.uid,
          "follower": 0,
          "following": 0,
          "reviews": 0,
          "bio": "",
          "created_on": Timestamp.now(),
          "profile_pic": photoUrl,
          "user_name": name,
          "email": email,
          "followerList": [],
          "reviewList": [],
          "followingList": [],
          "communityList": [],
          "delivered": 0,
          "token": token,
        });
      } else {
        await FirebaseFirestore.instance
            .collection("Drivers")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          "token": token,
        });
        print("=============== Already done ================");
      }
    } catch (e) {
      print(e);
    }
  }
}
