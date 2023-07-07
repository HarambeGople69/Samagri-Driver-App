import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutx/flutx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myapp/models/driver_model.dart';
import 'package:myapp/models/firebase_user_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/screens/dashboard_screen/shopping_favourite_screen.dart';
import 'package:myapp/screens/dashboard_screen/shopping_inprogress_screen.dart';
import 'package:myapp/screens/dashboard_screen/shopping_map_screen.dart';
import 'package:myapp/services/fetch_product/fetch_product.dart';
import 'package:myapp/services/phone_auth/phone_auth.dart';
import 'package:myapp/utils/color.dart';
import 'package:myapp/widget/our_elevated_button.dart';
import 'package:myapp/widget/our_setting_box_tile.dart';
import 'package:myapp/widget/our_setting_tile.dart';
import 'package:myapp/widget/our_sized_box.dart';
import 'package:page_transition/page_transition.dart';

import '../../controller/login_controller.dart';
import '../../models/driver_review_model.dart';
import '../../models/user_model_firebase.dart';
import '../../services/current_location/get_current_location.dart';
import '../../services/phone_auth/auth_service.dart';
import '../../widget/our_spinner.dart';

class ShoppingProfileScreen extends StatefulWidget {
  @override
  _ShoppingProfileScreenState createState() => _ShoppingProfileScreenState();
}

class _ShoppingProfileScreenState extends State<ShoppingProfileScreen> {
  Position? position;

  @override
  Widget build(BuildContext context) {
    return Obx(() => ModalProgressHUD(
          inAsyncCall: Get.find<LoginController>().processing.value,
          progressIndicator: OurSpinner(),
          child: Scaffold(
              body: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(
                ScreenUtil().setSp(20),
              ),
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    top: ScreenUtil().setSp(16),
                  ),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Drivers")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: OurSpinner(),
                        );
                      } else {
                        if (snapshot.hasData) {
                          DriverModel driverModel =
                              DriverModel.fromMap(snapshot.data!.data()!);
                          // FirebaseUserModel firebaseUserModel =
                          //     FirebaseUserModel.fromMap(snapshot.data!.data()!);
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: ScreenUtil().setSp(40),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        ScreenUtil().setSp(25),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: driverModel.profile_pic ?? "",

                                        // Image.network(
                                        placeholder: (context, url) =>
                                            Image.asset(
                                          "assets/images/profile_holder.png",
                                          width: double.infinity,
                                          height: ScreenUtil().setSp(125),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          "assets/images/profile_holder.png",
                                          width: double.infinity,
                                          height: ScreenUtil().setSp(125),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        height: ScreenUtil().setSp(100),
                                        width: ScreenUtil().setSp(100),
                                        fit: BoxFit.cover,
                                        //   )
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setSp(30),
                                  ),
                                  Expanded(
                                    child: Text(
                                      driverModel.user_name ?? "",
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(20),
                                        color: darklogoColor,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await GoogleAuth().logout(context);
                                    },
                                    child: Icon(
                                      MdiIcons.logout,
                                      color: darklogoColor,
                                      size: ScreenUtil().setSp(35),
                                    ),
                                  ),
                                  //                 MdiIcons.logout,
                                  // function: () async {
                                  //   // await FetchProductFirebase()
                                  //   //     .fetchproductfirebase("Grocery");
                                  //   // await PhoneAuth().logout();
                                  // GoogleAuth().logout(context);
                                ],
                              ),
                              OurSizedBox(),
                              Row(
                                children: [
                                  Text(
                                    "Total No of deliveries:",
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(17.5),
                                      color: darklogoColor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setSp(20),
                                  ),
                                  Text(
                                    driverModel.delivered.toString(),
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(20),
                                      color: darklogoColor,
                                    ),
                                  ),
                                ],
                              ),
                              OurSizedBox(),
                              Row(
                                children: [
                                  Text(
                                    "Total No of reviews:",
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(17.5),
                                      color: darklogoColor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setSp(20),
                                  ),
                                  Text(
                                    driverModel.reviews.toString(),
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(20),
                                      color: darklogoColor,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: darklogoColor,
                              ),
                              driverModel.reviews == 0
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          OurSizedBox(),
                                          OurSizedBox(),
                                          OurSizedBox(),
                                          Image.asset(
                                            "assets/images/logo.png",
                                            fit: BoxFit.contain,
                                            height: ScreenUtil().setSp(100),
                                            width: ScreenUtil().setSp(100),
                                          ),
                                          OurSizedBox(),
                                          Text(
                                            "We're sorry",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: logoColor,
                                              fontSize:
                                                  ScreenUtil().setSp(17.5),
                                            ),
                                          ),
                                          OurSizedBox(),
                                          Text(
                                            "You don't have any reviews yet",
                                            style: TextStyle(
                                              color: Colors.black45,
                                              fontSize: ScreenUtil().setSp(15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "All Reviews:",
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(20),
                                            color: darklogoColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Divider(
                                          color: darklogoColor,
                                        ),
                                        StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection("AllReviews")
                                              .where("driverUID",
                                                  isEqualTo: FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid)
                                              .orderBy(
                                                "created_On",
                                                descending: true,
                                              )
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot snapshot) {
                                            if (snapshot.hasData) {
                                              if (snapshot.data!.docs.length >
                                                  0) {
                                                return ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount: snapshot
                                                        .data!.docs.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      DriverReviewModel
                                                          driverReviewModel =
                                                          DriverReviewModel
                                                              .fromMap(snapshot
                                                                  .data!
                                                                  .docs[index]);
                                                      return Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              ScreenUtil()
                                                                  .setSp(7.5),
                                                          vertical: ScreenUtil()
                                                              .setSp(7.5),
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            ScreenUtil()
                                                                .setSp(10),
                                                          ),
                                                        ),
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              ScreenUtil()
                                                                  .setSp(5),
                                                          vertical: ScreenUtil()
                                                              .setSp(5),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              driverReviewModel
                                                                  .senderName,
                                                              style: TextStyle(
                                                                color:
                                                                    darklogoColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    ScreenUtil()
                                                                        .setSp(
                                                                            17.5),
                                                              ),
                                                            ),
                                                            OurSizedBox(),
                                                            Text(
                                                              driverReviewModel
                                                                  .review,
                                                              style: TextStyle(
                                                                color:
                                                                    logoColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize:
                                                                    ScreenUtil()
                                                                        .setSp(
                                                                            17.5),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              } else {
                                                return Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Spacer(),
                                                      Image.asset(
                                                        "assets/images/logo.png",
                                                        fit: BoxFit.contain,
                                                        height: ScreenUtil()
                                                            .setSp(100),
                                                        width: ScreenUtil()
                                                            .setSp(100),
                                                      ),
                                                      OurSizedBox(),
                                                      Text(
                                                        "We're sorry",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: logoColor,
                                                          fontSize: ScreenUtil()
                                                              .setSp(17.5),
                                                        ),
                                                      ),
                                                      OurSizedBox(),
                                                      Text(
                                                        "You have not sent any messages",
                                                        style: TextStyle(
                                                          color: Colors.black45,
                                                          fontSize: ScreenUtil()
                                                              .setSp(15),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                    ],
                                                  ),
                                                );
                                              }
                                            } else if (snapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              return OurSpinner();
                                            }
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Spacer(),
                                                  Image.asset(
                                                    "assets/images/logo.png",
                                                    fit: BoxFit.contain,
                                                    height:
                                                        ScreenUtil().setSp(100),
                                                    width:
                                                        ScreenUtil().setSp(100),
                                                  ),
                                                  OurSizedBox(),
                                                  Text(
                                                    "We're sorry",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: logoColor,
                                                      fontSize: ScreenUtil()
                                                          .setSp(17.5),
                                                    ),
                                                  ),
                                                  OurSizedBox(),
                                                  Text(
                                                    "",
                                                    style: TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: ScreenUtil()
                                                          .setSp(15),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                            ],
                          );
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: <Widget>[
                          //     FxText.sh1(
                          //       firebaseUserModel.name,
                          //       fontWeight: 700,
                          //       letterSpacing: 0,
                          //       color: darklogoColor,
                          //       fontSize: ScreenUtil().setSp(17.5),
                          //     ),
                          //     SizedBox(
                          //       height: ScreenUtil().setSp(5),
                          //     ),
                          //     FxText.caption(
                          //       firebaseUserModel.phone,
                          //       fontWeight: 500,
                          //       letterSpacing: 0.3,
                          //       color: darklogoColor,
                          //       fontSize: ScreenUtil().setSp(
                          //         15,
                          //       ),
                          //     ),
                          //   ],
                          // );
                        }
                        return Container();
                      }
                    },
                  ),
                ),
                OurSizedBox(),
                OurSizedBox(),
                // OurSettingTile(
                //   title: "Logout",
                //   iconData: MdiIcons.logout,
                //   function: () async {
                //     // await FetchProductFirebase()
                //     //     .fetchproductfirebase("Grocery");
                //     // await PhoneAuth().logout();
                //     GoogleAuth().logout(context);
                //     // var a = await FirebaseFirestore.instance
                //     //     .collection("Users")
                //     //     .doc(FirebaseAuth.instance.currentUser!.uid)
                //     //     .get();
                //     // FirebaseUser11Model userModel =
                //     //     FirebaseUser11Model.fromMap(a);
                //     // print(userModel.name);
                //   },
                // ),
              ],
            ),
          )),
        ));
  }
}
