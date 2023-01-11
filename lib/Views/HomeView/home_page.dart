// ignore: unused_import
import 'dart:developer' as logger;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cron/cron.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isd/Utils/colors.dart';
import 'package:isd/Utils/helpers.dart';
import 'package:isd/Views/ScannerPage/scanner_page.dart';
import 'package:location/location.dart';

import '../../Models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Location location = Location();

  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  double lat2 = 0.0;
  double lon2 = 0.0;
  final cron = Cron();
  //get location

  // get startTimerData => startTimer();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // startTimer() async {
  //   final data = await FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection("Attendance")
  //       .doc(DateFormat("ddMMyyyy").format(DateTime.now()))
  //       .get();
  //   if (data.exists) {
  //     cron.schedule(Schedule.parse('*/1 * * * *'), () async {
  //       if (lat2 != 0.0 && lon2 != 0.0) {
  //         final ndist =
  //             calculateDistance(lat2, lon2, 28.6264667, 77.3775161) * 1000;
  //         if (ndist < 10) {
  //           FirebaseFirestore.instance
  //               .collection('Users')
  //               .doc(FirebaseAuth.instance.currentUser!.uid)
  //               .collection("Attendance")
  //               .doc(DateFormat("ddMMyyyy").format(DateTime.now()))
  //               .update({
  //             'officeTime': FieldValue.increment(1),
  //           });
  //           Fluttertoast.showToast(
  //             msg: "You are out of office",
  //             toastLength: Toast.LENGTH_SHORT,
  //             gravity: ToastGravity.BOTTOM,
  //             timeInSecForIosWeb: 1,
  //             backgroundColor: Colors.red,
  //             textColor: Colors.white,
  //             fontSize: 16.0,
  //           );
  //         }
  //       }
  //     });
  //   }
  // }

  _checkLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    final permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {});
    // startTimer();

    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        lat2 = currentLocation.latitude!;
        lon2 = currentLocation.longitude!;
      });
    });
    // if (await location.isBackgroundModeEnabled() == false) {
    //   location.enableBackgroundMode(enable: true);
    // }
  }

  addSalutation() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning,";
    } else if (hour < 17) {
      return "Good Afternoon,";
    } else {
      return "Good Evening,";
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  String distance() {
    if (lat2 == 0.0 && lon2 == 0.0) {
      return "0.0";
    }
    final ndist = calculateDistance(lat2, lon2, 28.6264667, 77.3775161) * 1000;
    if (ndist > 1000) {
      return "${(ndist / 1000).toStringAsFixed(2)} km Away from Office";
    } else {
      return "${ndist.toStringAsFixed(2)} m Away from Office";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        toolbarHeight: 20,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addSalutation(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text(
                            "Welcome to ISD",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          );
                        }
                        return Text(
                          snapshot.data!.data()!['name'] == ""
                              ? snapshot.data!
                                  .data()!['email']
                                  .toString()
                                  .split("@")[0]
                                  .capitalizeFirst
                              : snapshot.data!.data()!['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Spacer(),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 23,
                          backgroundColor: primaryColor,
                        ),
                      );
                    }
                    final user = UserModel.fromDocument(snapshot.data!);
                    return CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 23,
                        backgroundColor: primaryColor,
                        backgroundImage:
                            user.photoUrl != null && user.photoUrl != ""
                                ? NetworkImage(user.photoUrl!)
                                : null,
                        child: user.photoUrl == null || user.photoUrl == ""
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Your Location",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    Icons.location_on,
                    color: primaryColor,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      if (_permissionGranted == PermissionStatus.denied ||
                          _locationData == null) {
                        _checkLocationPermission();
                      } else {
                        null;
                      }
                    },
                    child: Text(
                      _locationData == null
                          ? "Loading..."
                          : _permissionGranted == PermissionStatus.denied
                              ? "Location Permission Denied"
                              : distance(),
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "In Time",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('Attendance')
                            .doc((DateTime.now().day < 10
                                    ? "0${DateTime.now().day}"
                                    : DateTime.now().day.toString()) +
                                (DateTime.now().month < 10
                                    ? "0${DateTime.now().month}"
                                    : DateTime.now().month.toString()) +
                                DateTime.now().year.toString())
                            .snapshots(),
                        builder: (context, snapshot) {
                          String title = "Loading...";
                          if (snapshot.hasData == false) {
                            title = "Loading...";
                          } else if (snapshot.data!.exists == false) {
                            title = "Not In Yet";
                          } else if (snapshot.data!.get('indateTime') == null) {
                            title = "Not In Yet";
                          } else {
                            title = DateFormat('hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                int.parse(snapshot.data!.get('indateTime')),
                              ),
                            );
                          }
                          return Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  color: primaryColor,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    title,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Out Time",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('Attendance')
                            .doc((DateTime.now().day < 10
                                    ? "0${DateTime.now().day}"
                                    : DateTime.now().day.toString()) +
                                (DateTime.now().month < 10
                                    ? "0${DateTime.now().month}"
                                    : DateTime.now().month.toString()) +
                                DateTime.now().year.toString())
                            .snapshots(),
                        builder: (context, snapshot) {
                          String title = "Loading...";
                          if (snapshot.hasData == false) {
                            title = "Loading...";
                          } else if (snapshot.data!.exists == false) {
                            title = "Not Out Yet";
                          } else if (snapshot.data!.get('outdateTime') == "") {
                            title = "Not Out Yet";
                          } else {
                            title = DateFormat('hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                int.parse(snapshot.data!.get('outdateTime')),
                              ),
                            );
                          }
                          return Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  color: primaryColor,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    title,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "This Month Attendance",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('Holidays')
                    .doc('stpyAWihYEkKupbuJHgd')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  int workingDays = 0;
                  String month =
                      DateFormat('MMM').format(DateTime.now()).toLowerCase();
                  List<dynamic> holidays = snapshot.data!.get(month);
                  workingDays = daysInMonth() - holidays.length;

                  return Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Working Days",
                              style: TextStyle(
                                color: backColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "$workingDays Days",
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const VerticalDivider(
                          color: primaryColor,
                          thickness: 1,
                        ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('Attendance')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text(
                                "Loading...",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Present",
                                  style: TextStyle(
                                    color: backColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "${calculatePresent(snapshot.data!.docs)} Days",
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const VerticalDivider(
                          color: primaryColor,
                          thickness: 1,
                        ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('Attendance')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text(
                                "Loading...",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }
                            int absent = 0;
                            absent = calculateAbsent(
                              calculatePresent(snapshot.data!.docs),
                              holidays,
                            );
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Absent",
                                  style: TextStyle(
                                    color: backColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "$absent Days",
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
            const SizedBox(
              height: 20,
            ),
            // Add Attendance
            Hero(
              tag: "addAttendance",
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () async {
                      if (_locationData == null ||
                          await location.serviceEnabled() == false) {
                        _checkLocationPermission();
                        return;
                      }
                      if (calculateDistance(
                                  lat2, lon2, 28.6264667, 77.3775161) *
                              1000 >
                          10) {
                        Fluttertoast.cancel();
                        Fluttertoast.showToast(
                          msg: "You are not in Office",
                          backgroundColor: Colors.red,
                        );
                      } else {
                        showLoader();
                        final date = (DateTime.now().day < 10
                                ? "0${DateTime.now().day}"
                                : DateTime.now().day.toString()) +
                            (DateTime.now().month < 10
                                ? "0${DateTime.now().month}"
                                : DateTime.now().month.toString()) +
                            DateTime.now().year.toString();
                        final data = await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('Attendance')
                            .doc(date)
                            .get();
                        if (data.exists) {
                          Get.back();
                          if (data.get('indateTime') != "" &&
                              data.get('outdateTime') != "") {
                            Fluttertoast.cancel();
                            Fluttertoast.showToast(
                              msg: "Attendance Added",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                            );
                          } else if (data.get('indateTime') != null &&
                              data.get('outdateTime') == "") {
                            final inTime = DateTime.fromMillisecondsSinceEpoch(
                                int.parse(data.get('indateTime')));
                            final outTime = DateTime.now();
                            final difference = outTime.difference(inTime);
                            logger.log(difference.inHours.toString());
                            final hours = difference.inHours;
                            if (hours <= 2) {
                              Fluttertoast.cancel();
                              Fluttertoast.showToast(
                                msg: "Already Checked In Wait for 2 Hours",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                              );
                            } else {
                              Get.to(
                                () => const ScannerPage(
                                  isIncoming: false,
                                ),
                              );
                            }
                          }
                        } else {
                          Get.back();
                          Get.to(
                            () => const ScannerPage(
                              isIncoming: true,
                            ),
                          );
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.qr_code_scanner,
                          color: primaryColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Scan QR Code",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            Text(
              "Attendance Calendar ( ${DateFormat('MMMM yyyy').format(DateTime.now())} )",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('Attendance')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: daysInMonth(),
                    itemBuilder: (_, i) {
                      final nowday =
                          (i + 1) < 10 ? "0${i + 1}" : (i + 1).toString();
                      final allDocs = snapshot.data!.docs
                          .where((element) =>
                              element.id[2] + element.id[3] ==
                              (DateTime.now().month < 10
                                  ? "0${DateTime.now().month}"
                                  : DateTime.now().month.toString()))
                          .toList();
                      final dataIndex = allDocs.indexWhere(
                        (element) =>
                            element.id[0] + element.id[1] == nowday.toString(),
                      );

                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black,
                        child: CircleAvatar(
                          radius: 17.5,
                          backgroundColor: dataIndex == -1
                              ? Colors.orange
                              : snapshot.data!.docs[dataIndex]
                                          .get('indateTime') !=
                                      ""
                                  ? Colors.blue
                                  : Colors.green,
                          child: Text(
                            dataIndex == -1
                                ? (i + 1).toString()
                                : snapshot.data!.docs[dataIndex]
                                            .get('indateTime') !=
                                        ""
                                    ? "P"
                                    : "A",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  calculatePresent(List<QueryDocumentSnapshot<Map<String, dynamic>>> data) {
    int present = 0;
    for (var i = 0; i < data.length; i++) {
      if (data[i].id.substring(2, 4) ==
          (DateTime.now().month < 10
              ? "0${DateTime.now().month}"
              : DateTime.now().month.toString())) {
        present++;
      }
    }
    return present;
  }

  List days = const [
    "S",
    "M",
    "T",
    "W",
    "T",
    "F",
    "S",
  ];

  daysInMonth() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.difference(firstDayOfMonth).inDays + 1;
    return daysInMonth;
  }

  calculateAbsent(int present, List<dynamic> holidays) {
    List<String> days = [];
    for (var i = 0; i < daysInMonth(); i++) {
      days.add((i + 1).toString());
    }
    return days.length - present - holidays.length;
  }
}
