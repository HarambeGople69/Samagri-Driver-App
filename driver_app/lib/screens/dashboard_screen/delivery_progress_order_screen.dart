import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myapp/services/open_map/open_map.dart';
import 'package:myapp/services/pick_order/pick_order_service.dart';
import 'package:myapp/widget/our_elevated_button.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../controller/login_controller.dart';
import '../../models/inprogress_product_model.dart';
import '../../services/network_connection/network_connection.dart';
import '../../utils/color.dart';
import '../../widget/our_flutter_toast.dart';
import '../../widget/our_sized_box.dart';
import '../../widget/our_spinner.dart';

class DeliveryProgressOrderScreen extends StatefulWidget {
  const DeliveryProgressOrderScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryProgressOrderScreen> createState() =>
      _DeliveryProgressOrderScreenState();
}

class _DeliveryProgressOrderScreenState
    extends State<DeliveryProgressOrderScreen> with TickerProviderStateMixin {
  late AnimationController animationControllerListPage;
  late Animation<double> logoAnimationList;
  late Animation<double> fadeAnimation;
  late AnimationController animationController;

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    animationControllerListPage.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    animationControllerListPage = AnimationController(
      duration: Duration(milliseconds: 900),
      vsync: this,
    );

    logoAnimationList = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: animationControllerListPage,
        curve: Curves.linear,
      ),
    );
    animationControllerListPage.repeat(reverse: true);
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
    );
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: Get.find<LoginController>().processing.value,
        progressIndicator: OurSpinner(),
        child: Scaffold(
          body: SafeArea(
              child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setSp(10),
              vertical: ScreenUtil().setSp(10),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: logoAnimationList,
                        child: Image.asset(
                          "assets/images/logo.png",
                          height: ScreenUtil().setSp(23.5),
                          width: ScreenUtil().setSp(23.5),
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setSp(7.5),
                      ),
                      Text(
                        "My Progress Orders",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: ScreenUtil().setSp(25),
                          color: darklogoColor,
                        ),
                      ),
                    ],
                  ),
                ),
                OurSizedBox(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("Orders")
                        .where("driverUid",
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .where("isDelivered", isEqualTo: false)
                        .orderBy(
                          "orderedAt",
                          descending: true,
                        )
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: OurSpinner(),
                        );
                      } else if (snapshot.hasData) {
                        if (snapshot.data!.docs.length > 0) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    InProgressProductModel
                                        inProgressProductModel =
                                        InProgressProductModel.fromMap(
                                            (snapshot.data!.docs[index].data()
                                                as Map<String, dynamic>));
                                    // InProgressProductModel
                                    //     inProgressProductModel =
                                    //     InProgressProductModel.fromMap(
                                    //         snapshot.data!.docs[index]);
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: ScreenUtil().setSp(5),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: ScreenUtil().setSp(5),
                                        vertical: ScreenUtil().setSp(5),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          ScreenUtil().setSp(10),
                                        ),
                                      ),
                                      child: ExpansionTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Order id:",
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(17.5),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: ScreenUtil().setSp(5),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    inProgressProductModel.uid,
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(15),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            OurSizedBox(),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Delivery Address:",
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(17.5),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: ScreenUtil().setSp(5),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    inProgressProductModel
                                                        .deliveryAddress,
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(15),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            OurSizedBox(),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Delivery Time:",
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(17.5),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: ScreenUtil().setSp(5),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    inProgressProductModel
                                                        .deliveryTime
                                                        .split("tomorrow")[0],
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(15),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            OurSizedBox(),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Ordered On:",
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(17.5),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: ScreenUtil().setSp(5),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    inProgressProductModel
                                                        .orderedAt
                                                        .toDate()
                                                        .toString()
                                                        .split(".")[0],
                                                    // ,
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(15),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                )
                                              ],
                                            ),
                                            OurSizedBox(),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Payment Type:",
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(17.5),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: ScreenUtil().setSp(5),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    inProgressProductModel
                                                        .paymentType,
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(15),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            OurSizedBox(),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Total Price:",
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(17.5),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: ScreenUtil().setSp(5),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    "Rs. ${inProgressProductModel.totalPrice.toString()}",
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(15),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            OurSizedBox(),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Phone No:",
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(17.5),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: ScreenUtil().setSp(5),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    "${inProgressProductModel.userPhoneNo}",
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(15),
                                                      color: darklogoColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            OurSizedBox(),
                                            Center(
                                              child: OurElevatedButton(
                                                title: "View delivery location",
                                                function: () async {
                                                  if (Get.find<
                                                              CheckConnectivity>()
                                                          .isOnline ==
                                                      false) {
                                                    OurToast().showErrorToast(
                                                        "Oops, No internet connection");
                                                  } else {
                                                    await OpenMap()
                                                        .viewLocation(
                                                      inProgressProductModel
                                                          .lat,
                                                      inProgressProductModel
                                                          .long,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            OurSizedBox(),
                                            Center(
                                              child: OurElevatedButton(
                                                title: "Deliver Order",
                                                function: () async {
                                                  if (Get.find<
                                                              CheckConnectivity>()
                                                          .isOnline ==
                                                      false) {
                                                    OurToast().showErrorToast(
                                                        "Oops, No internet connection");
                                                  } else {
                                                    _showMyDialog(
                                                      inProgressProductModel
                                                          .verifyToken
                                                          .toString(),
                                                      inProgressProductModel,
                                                    );
                                                    // await PickOrderService()
                                                    //     .pickOrder(
                                                    //         inProgressProductModel);
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        children: inProgressProductModel.items
                                            .map((e) => StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection("RequestOrder")
                                                    .doc(e.toString())
                                                    .snapshots(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                      child: OurSpinner(),
                                                    );
                                                  } else if (snapshot.hasData) {
                                                    return Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                        vertical: ScreenUtil()
                                                            .setSp(3.5),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              8)),
                                                              child:
                                                                  // Image.network(
                                                                  //   widget.cartProductModel.url[0],
                                                                  //   height: ScreenUtil().setSp(90),
                                                                  //   fit: BoxFit.fill,
                                                                  // ),
                                                                  CachedNetworkImage(
                                                                height:
                                                                    ScreenUtil()
                                                                        .setSp(
                                                                            90),
                                                                fit:
                                                                    BoxFit.fill,
                                                                imageUrl: snapshot
                                                                        .data[
                                                                    "productImage"],
                                                                placeholder: (context,
                                                                        url) =>
                                                                    Image.asset(
                                                                  "assets/images/placeholder.png",
                                                                  height:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              90),
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: ScreenUtil()
                                                                .setSp(10),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "Product Name:",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            15),
                                                                    color:
                                                                        darklogoColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                OurSizedBox(),
                                                                Text(
                                                                  snapshot.data[
                                                                      "productName"],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            13.5),
                                                                    color:
                                                                        darklogoColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "Quantity:",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            15),
                                                                    color:
                                                                        darklogoColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                OurSizedBox(),
                                                                Text(
                                                                  snapshot.data[
                                                                          "quantity"]
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            13.5),
                                                                    color:
                                                                        darklogoColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "Product price:",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            15),
                                                                    color:
                                                                        darklogoColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                OurSizedBox(),
                                                                Text(
                                                                  snapshot.data[
                                                                          "price"]
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            13.5),
                                                                    color:
                                                                        darklogoColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    var a = await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "Sellers")
                                                                        .doc(snapshot
                                                                            .data["productOwnerId"])
                                                                        .get();
                                                                    print(a[
                                                                        "lat"]);
                                                                    print(a[
                                                                        "long"]);
                                                                    await OpenMap()
                                                                        .viewLocation(
                                                                      a["lat"],
                                                                      a["long"],
                                                                    );
                                                                    // print(a
                                                                    //     .get());
                                                                  },
                                                                  child: Text(
                                                                    "Pick",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          ScreenUtil()
                                                                              .setSp(12.5),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  return OurSpinner();
                                                }))
                                            .toList(),
                                      ),
                                    );

                                    //
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/logo.png",
                                  fit: BoxFit.contain,
                                  height: ScreenUtil().setSp(150),
                                  width: ScreenUtil().setSp(150),
                                ),
                                OurSizedBox(),
                                Text(
                                  "We're sorry",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: logoColor,
                                    fontSize: ScreenUtil().setSp(17.5),
                                  ),
                                ),
                                OurSizedBox(),
                                Text(
                                  "No order in progress",
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: ScreenUtil().setSp(15),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/logo.png",
                              fit: BoxFit.contain,
                              height: ScreenUtil().setSp(150),
                              width: ScreenUtil().setSp(150),
                            ),
                            OurSizedBox(),
                            Text(
                              "We're sorry",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: logoColor,
                                fontSize: ScreenUtil().setSp(17.5),
                              ),
                            ),
                            OurSizedBox(),
                            Text(
                              "No order in progress",
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: ScreenUtil().setSp(15),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(
      String otp, InProgressProductModel inProgressProductModel) async {
    final TextEditingController _pinPutController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  "Enter Verification OTP",
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(24.5),
                      color: darklogoColor,
                      fontWeight: FontWeight.w500),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OurSizedBox(),
                  PinFieldAutoFill(
                    controller: _pinPutController,
                    decoration: CirclePinDecoration(
                      strokeWidth: 1,
                      gapSpace: ScreenUtil().setSp(10),
                      textStyle: TextStyle(
                        color: darklogoColor,
                        fontSize: ScreenUtil().setSp(17.5),
                      ),
                      strokeColorBuilder: FixedColorBuilder(
                        logoColor,
                      ),
                    ),
                    currentCode: "",
                    codeLength: 6,
                    onCodeChanged: (code) {
                      print(_pinPutController.text.trim());
                    },
                    onCodeSubmitted: (val) {
                      print("onCodeSubmitted $val");
                    },
                  ),
                  OurSizedBox(),
                  InkWell(
                    onTap: () async {
                      if (otp == _pinPutController.text.trim()) {
                        Navigator.pop(context);

                        await PickOrderService()
                            .deliverOrder(inProgressProductModel);
                        OurToast().showSuccessToast("Success");
                      } else {
                        OurToast()
                            .showSuccessToast("Oops, You entered wrong OTP.");
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setSp(10),
                        vertical: ScreenUtil().setSp(5),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ScreenUtil().setSp(
                            15,
                          ),
                        ),
                        color: logoColor,
                      ),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(17.5),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
