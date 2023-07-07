import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:myapp/models/inprogress_product_model.dart';
import 'package:uuid/uuid.dart';

import '../../controller/login_controller.dart';
import '../notification_service/notification_service.dart';

class PickOrderService {
  pickOrder(InProgressProductModel inProgressProductModel) async {
    Get.find<LoginController>().toggle(true);
    try {
      var a = await FirebaseFirestore.instance
          .collection("Drivers")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      await FirebaseFirestore.instance
          .collection("Orders")
          .doc(inProgressProductModel.uid)
          .update({
        "driverUid": FirebaseAuth.instance.currentUser!.uid,
        "driverName": a["user_name"],
        "status": "Order picked",
      });
      var b = await FirebaseFirestore.instance
          .collection("Users")
          .doc(inProgressProductModel.ownerId)
          .get();
      await NotificationService().sendNotification(
        "Your parcel has been picked",
        "Your parcel(id: ${inProgressProductModel.uid}) has been picked by driver ${a["user_name"]} ",
        "userModel.profile_pic",
        "",
        b["token"],
      );
      var uniqueNotificationUId = Uuid().v4();
      await FirebaseFirestore.instance
          .collection("Notifications")
          .doc(inProgressProductModel.ownerId)
          .collection("MyNotifications")
          .doc(uniqueNotificationUId)
          .set({
        "uid": uniqueNotificationUId,
        "productName": "abcd",
        "productImage": "abcd",
        "senderName": a["user_name"],
        "desc":
            "Your parcel(id: ${inProgressProductModel.uid} has been picked by driver ${a["user_name"]}) ",
        "addedOn": Timestamp.now(),
      });
      Get.find<LoginController>().toggle(false);
    } catch (e) {
      Get.find<LoginController>().toggle(false);
    }
  }

  deliverOrder(InProgressProductModel inProgressProductModel) async {
    Get.find<LoginController>().toggle(true);
    try {
      var a = await FirebaseFirestore.instance
          .collection("Drivers")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      await FirebaseFirestore.instance
          .collection("Orders")
          .doc(inProgressProductModel.uid)
          .update({
        "isDelivered": true,
        "status": "Order Delivered",
      });
      await FirebaseFirestore.instance
          .collection("Drivers")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        "delivered": a.data()!["delivered"] + 1,
      });
      var b = await FirebaseFirestore.instance
          .collection("Users")
          .doc(inProgressProductModel.ownerId)
          .get();
      await NotificationService().sendNotification(
        "Your parcel has been delivered",
        "Your parcel(id: ${inProgressProductModel.uid}) has been delivered by driver ${a["user_name"]} ",
        "userModel.profile_pic",
        "",
        b["token"],
      );
      var uniqueNotificationUId = Uuid().v4();
      await FirebaseFirestore.instance
          .collection("Notifications")
          .doc(inProgressProductModel.ownerId)
          .collection("MyNotifications")
          .doc(uniqueNotificationUId)
          .set({
        "uid": uniqueNotificationUId,
        "productName": "abcd",
        "productImage": "abcd",
        "senderName": a["user_name"],
        "desc":
            "Your parcel(id: ${inProgressProductModel.uid} has been delivered by driver ${a["user_name"]}) ",
        "addedOn": Timestamp.now(),
      });
      Get.find<LoginController>().toggle(false);
    } catch (e) {
      Get.find<LoginController>().toggle(false);
    }
  }
}
