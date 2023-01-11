// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isd/Controllers/sound_controller.dart';
import 'package:isd/Utils/colors.dart';
import 'package:isd/Utils/helpers.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerPage extends StatefulWidget {
  final bool isIncoming;
  const ScannerPage({
    Key? key,
    required this.isIncoming,
  }) : super(key: key);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    this.controller!.resumeCamera();
    this.controller!.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      final date = (DateTime.now().day < 10
              ? "0${DateTime.now().day}"
              : DateTime.now().day.toString()) +
          (DateTime.now().month < 10
              ? "0${DateTime.now().month}"
              : DateTime.now().month.toString()) +
          DateTime.now().year.toString();
      if (result != null && result!.code == "https://payuzi.in/at.php") {
        controller.pauseCamera();
        showLoader();
        getQrData().then((value) {
          log(date);
          if (value == date) {
            addAttendance();
          } else {
            Get.back();
            Fluttertoast.cancel();
            Fluttertoast.showToast(
              msg: "Invalid QR Code",
              timeInSecForIosWeb: 3,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        });
      } else {
        Fluttertoast.cancel();
        Fluttertoast.showToast(
          msg: "Invalid QR Code Scan Again",
          timeInSecForIosWeb: 3,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });
  }

  getQrData() async {
    final data = await http.get(Uri.parse("https://payuzi.in/at.php"));
    log(data.body.toString());
    return data.body.toString();
  }

  addAttendance() async {
    final date = (DateTime.now().day < 10
            ? "0${DateTime.now().day}"
            : DateTime.now().day.toString()) +
        (DateTime.now().month < 10
            ? "0${DateTime.now().month}"
            : DateTime.now().month.toString()) +
        DateTime.now().year.toString();
    final data = await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Attendance")
        .doc(
          date,
        )
        .get();
    if (data.exists) {
      if (widget.isIncoming) {
        if (data.data()!['indateTime'] != "") {
          Get.back();
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: "You have already checked In",
            timeInSecForIosWeb: 3,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }
      } else {
        if (data.data()!['outdateTime'] != "") {
          Get.back();
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: "You have already checked Out",
            timeInSecForIosWeb: 3,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        } else {
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection("Attendance")
              .doc(
                date,
              )
              .update({
            "outdateTime": DateTime.now().millisecondsSinceEpoch.toString(),
          });
          Provider.of<SoundController>(context, listen: false).outsoundPlay();
          Get.back();
          Get.back();
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: "Check Out Recorded Successfully",
            timeInSecForIosWeb: 3,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } else {
      Map<String, dynamic> incomingData = {
        "indateTime": DateTime.now().millisecondsSinceEpoch.toString(),
        'outdateTime': '',
      };

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("Attendance")
          .doc(
            date,
          )
          .set(incomingData);
      Provider.of<SoundController>(context, listen: false).insoundPlay();

      Get.back();
      Get.back();
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: "Attendance Recorded Successfully",
        timeInSecForIosWeb: 3,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(),
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            width: 250,
            height: 250,
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.isIncoming
                ? "Scan QR Code to Check In"
                : "Scan QR Code to Check Out",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(
            height: kToolbarHeight + 20,
          ),
        ],
      ),
    );
  }
}
