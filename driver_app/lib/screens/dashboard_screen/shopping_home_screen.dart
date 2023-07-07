import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/controller/category_tag_controller.dart';
import 'package:myapp/db/db_helper.dart';
import 'package:myapp/models/recommendation_history_model.dart';
import 'package:myapp/screens/dashboard_screen/shopping_notification_screen.dart';
import 'package:myapp/screens/dashboard_screen/shopping_search_product_screen.dart';
import 'package:myapp/services/current_location/get_current_location.dart';
import 'package:myapp/utils/color.dart';
import 'package:myapp/widget/our_category_context.dart';
import 'package:myapp/widget/our_shimmer_widget.dart';
import 'package:myapp/widget/our_sized_box.dart';
import 'package:page_transition/page_transition.dart';
import '../../models/category_model.dart';
import '../../models/lat_long_controller.dart';
import '../../services/network_connection/network_connection.dart';
import '../../widget/our_all_content.dart';
import '../../widget/our_carousel_slider.dart';
import 'package:scroll_to_id/scroll_to_id.dart';

import '../../widget/our_recommendation_widget.dart';
import 'delivery_available_order_screen.dart';
import 'delivery_history_order_screen.dart';
import 'delivery_progress_order_screen.dart';

class ShoppingHomeScreen extends StatefulWidget {
  const ShoppingHomeScreen({Key? key}) : super(key: key);

  @override
  _ShoppingHomeScreenState createState() => _ShoppingHomeScreenState();
}

class _ShoppingHomeScreenState extends State<ShoppingHomeScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _search_controller = TextEditingController();
  String category = "All";
  final scrollController = ScrollController();
  final items = [
    "All",
    "Grocery",
    "Electronic",
    "Beverage",
    "Personal care",
    "Fashain and apparel",
    "Baby care",
    "Bakery and dairy",
    "Eggs and meat",
    "Household items",
    "Kitchen and pet food",
    "Vegetable and fruits",
    "Beauty",
  ];

  late Tween<Offset> offset;
  int tag = 0;
  List<Placemark>? placeMarks;
  late AnimationController animationController;
  late AnimationController logoanimationController;
  late Animation<double> bellAnimation;
  late Animation<double> logoAnimation;
  late ScrollToId scrollToId;
  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // print(scrollToId.idPosition());
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    Get.find<CheckConnectivity>().initialize();

    // showIntroData();
    Get.find<CategoryTagController>().initialize();
    animationController = AnimationController(
      duration: Duration(milliseconds: 900),
      vsync: this,
    );
    bellAnimation = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.linear,
      ),
    );
    scrollToId = ScrollToId(scrollController: scrollController);
    scrollController.addListener(_scrollListener);

    logoAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.linear,
      ),
    );
    animationController.repeat(reverse: true);
  }

  Future<void> showIntroData() async {
    await Future.delayed(
      Duration(
        seconds: 1,
      ),
    ).then((value) async {
      if (Hive.box<int>(DatabaseHelper.introHelperDB)
              .get("state", defaultValue: 0) ==
          0) {
        print(Hive.box<int>(DatabaseHelper.introHelperDB).get("state"));
        await Future.delayed(Duration(seconds: 3)).then((value) {
          Intro.of(context).start();

          print("Hello Utsav");
        });
        print("First Time");
        await Hive.box<int>(DatabaseHelper.introHelperDB).put("state", 1);
      } else {
        print(Hive.box<int>(DatabaseHelper.introHelperDB).get("state"));
        print("Already done");
      }
    });
    Position? position = await GetCurrentLocation().getCurrentLocation();
    if (position != null) {
      print(position);
      placeMarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Get.find<LatLongController>()
          .changeLocation(position.latitude, position.longitude);
      Placemark pMark = placeMarks![1];
      print(pMark);
      String completeAddress =
          "${pMark.subLocality}, ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ";
      print(completeAddress);
      await Hive.box<String>(DatabaseHelper.nearbylocationDB)
          .put("state", completeAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        // drawer: Container(
        //   width: MediaQuery.of(context).size.width * 0.75,
        //   child: Drawer(),
        // ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    ScreenUtil().setSp(7.5),
                  ),
                ),
                height: ScreenUtil().setSp(40),
                padding: EdgeInsets.only(
                  top: ScreenUtil().setSp(2.5),
                  left: ScreenUtil().setSp(10),
                  right: ScreenUtil().setSp(10),
                ),
                margin: EdgeInsets.only(
                  top: ScreenUtil().setSp(10),
                  right: ScreenUtil().setSp(10),
                  left: ScreenUtil().setSp(10),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: ScreenUtil().setSp(12.5),
                    ),
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RotationTransition(
                              turns: logoAnimation,
                              child: Image.asset(
                                "assets/images/logo.png",
                                height: ScreenUtil().setSp(22.5),
                                width: ScreenUtil().setSp(22.5),
                              ),
                            ),
                            SizedBox(
                              width: ScreenUtil().setSp(7.5),
                            ),
                            Text(
                              "Go Mart: Driver",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenUtil().setSp(20.5),
                                color: darklogoColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: DeliveryAvailableOrderScreen(),
                              type: PageTransitionType.leftToRight),
                        );
                        // print("New Available Orders");
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            ScreenUtil().setSp(20),
                          ),
                          color: Color.fromARGB(255, 194, 161, 134),
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setSp(7.5),
                          vertical: ScreenUtil().setSp(7),
                        ),
                        height: ScreenUtil().setSp(250),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.list_alt,
                              color: Colors.white,
                              size: ScreenUtil().setSp(45),
                            ),
                            OurSizedBox(),
                            Text(
                              "New Available orders",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(17),
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: DeliveryProgressOrderScreen(),
                              type: PageTransitionType.leftToRight),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            ScreenUtil().setSp(20),
                          ),
                          color: Color.fromARGB(255, 178, 194, 134),
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setSp(7.5),
                          vertical: ScreenUtil().setSp(7),
                        ),
                        height: ScreenUtil().setSp(250),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delivery_dining_sharp,
                              color: Colors.white,
                              size: ScreenUtil().setSp(45),
                            ),
                            OurSizedBox(),
                            Text(
                              "Parcel in Progress",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(17),
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: DeliveryHistoryOrderScreen(),
                              type: PageTransitionType.leftToRight),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            ScreenUtil().setSp(20),
                          ),
                          color: Color.fromARGB(255, 134, 163, 194),
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setSp(7.5),
                          vertical: ScreenUtil().setSp(7),
                        ),
                        height: ScreenUtil().setSp(250),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.done_all,
                              color: Colors.white,
                              size: ScreenUtil().setSp(45),
                            ),
                            OurSizedBox(),
                            Text(
                              "History",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(17),
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
              // ScrollContent(
              //   id: "Utsav1",
              //   child: OurSizedBox(),
              // ),
              // ScrollContent(
              //   id: "id1",
              //   child: IntroStepBuilder(
              //     order: 3,
              //     text: 'Product priority based on location',
              //     borderRadius: BorderRadius.all(
              //       Radius.circular(
              //         ScreenUtil().setSp(25),
              //       ),
              //     ),
              //     builder: (context, key) => Container(
              //       margin: EdgeInsets.symmetric(
              //         horizontal: ScreenUtil().setSp(10),
              //       ),
              //       child: InkWell(
              //         key: key,
              //         onTap: () {},
              //         child: Row(
              //           // mainAxisAlignment: MainAxisAlignment.start,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Icon(
              //               FeatherIcons.mapPin,
              //               color: logoColor,
              //               size: ScreenUtil().setSp(20.5),
              //             ),
              //             SizedBox(
              //               width: ScreenUtil().setSp(12.5),
              //             ),
              //             Text(
              //               "Nearby:",
              //               style: TextStyle(
              //                 fontSize: ScreenUtil().setSp(17.5),
              //                 fontWeight: FontWeight.w700,
              //                 color: darklogoColor,
              //               ),
              //             ),
              //             SizedBox(
              //               width: ScreenUtil().setSp(12.5),
              //             ),
              //             ValueListenableBuilder(
              //               valueListenable: Hive.box<String>(
              //                       DatabaseHelper.nearbylocationDB)
              //                   .listenable(),
              //               builder: (context, Box<String> boxs, child) {
              //                 String value = boxs.get("state",
              //                     defaultValue: "Select location")!;
              //                 print("===========");
              //                 print(value);
              //                 print("===========");
              //                 return Expanded(
              //                   child: Text(
              //                     value,
              //                     style: TextStyle(
              //                       fontSize: ScreenUtil().setSp(15),
              //                       fontWeight: FontWeight.w500,
              //                       color: logoColor,
              //                     ),
              //                   ),
              //                 );
              //               },
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // ScrollContent(
              //   id: "Utsav2",
              //   child: OurSizedBox(),
              // ),
              // ScrollContent(
              //   id: "id2",
              //   child: Container(
              //     margin: EdgeInsets.symmetric(
              //       horizontal: ScreenUtil().setSp(10),
              //     ),
              //     child: OurCarousel(),
              //   ),
              // ),
              // ScrollContent(
              //   id: "Utsav3",
              //   child: OurSizedBox(),
              // ),
              // ScrollContent(
              //   id: "id3",
              //   child: IntroStepBuilder(
              //     order: 4,
              //     text: 'Get category wise products here',
              //     borderRadius: BorderRadius.all(
              //       Radius.circular(
              //         ScreenUtil().setSp(25),
              //       ),
              //     ),
              //     builder: (context, key) => Container(
              //       margin: EdgeInsets.symmetric(
              //         horizontal: ScreenUtil().setSp(
              //           10,
              //         ),
              //       ),
              //       child: SizedBox(
              //         key: key,
              //         height: ScreenUtil().setSp(50),
              //         child: AnimationLimiter(
              //             child: ListView.builder(
              //                 scrollDirection: Axis.horizontal,
              //                 shrinkWrap: true,
              //                 itemCount: items.length,
              //                 itemBuilder: (context, index) {
              //                   return AnimationConfiguration.staggeredList(
              //                     position: index,
              //                     duration: Duration(milliseconds: 700),
              //                     child: SlideAnimation(
              //                       horizontalOffset:
              //                           MediaQuery.of(context).size.width,
              //                       child: FadeInAnimation(
              //                         child: Obx(
              //                           () => InkWell(
              //                             onTap: () {
              //                               if (index == 0) {
              //                                 Get.find<
              //                                         CategoryTagController>()
              //                                     .changeTag(0, "All");
              //                                 scrollToId.animateTo(
              //                                   "All",
              //                                   duration: Duration(
              //                                       milliseconds: 500),
              //                                   curve: Curves.ease,
              //                                 );
              //                               } else {
              //                                 Get.find<
              //                                         CategoryTagController>()
              //                                     .changeTag(
              //                                   index,
              //                                   items[index],
              //                                 );
              //                                 scrollToId.animateTo(
              //                                   items[index],
              //                                   duration: Duration(
              //                                       milliseconds: 500),
              //                                   curve: Curves.ease,
              //                                 );
              //                               }
              //                             },
              //                             child: Container(
              //                               decoration: BoxDecoration(
              //                                 borderRadius:
              //                                     BorderRadius.circular(
              //                                   ScreenUtil().setSp(
              //                                     20,
              //                                   ),
              //                                 ),
              //                                 color: index ==
              //                                         Get.find<
              //                                                 CategoryTagController>()
              //                                             .tag
              //                                             .value
              //                                     ? logoColor
              //                                         .withOpacity(0.45)
              //                                     : Colors.grey
              //                                         .withOpacity(0.4),
              //                               ),
              //                               margin: EdgeInsets.symmetric(
              //                                 horizontal:
              //                                     ScreenUtil().setSp(2),
              //                                 vertical: ScreenUtil().setSp(2),
              //                               ),
              //                               padding: EdgeInsets.symmetric(
              //                                 horizontal:
              //                                     ScreenUtil().setSp(5),
              //                                 vertical: ScreenUtil().setSp(5),
              //                               ),
              //                               child: Center(
              //                                 child: Text(
              //                                   items[index],
              //                                   style: TextStyle(
              //                                     fontWeight: FontWeight.w400,
              //                                     fontSize: ScreenUtil()
              //                                         .setSp(13.5),
              //                                     color: index ==
              //                                             Get.find<
              //                                                     CategoryTagController>()
              //                                                 .tag
              //                                                 .value
              //                                         ? Colors.white
              //                                         : Colors.black,
              //                                   ),
              //                                 ),
              //                               ),
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                     ),
              //                   );
              //                 })),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
