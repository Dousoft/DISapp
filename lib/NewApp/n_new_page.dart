import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../Controllers/sound_controller.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({Key? key}) : super(key: key);

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
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
      if (result != null) {
        // controller.pauseCamera();
        // showLoader();
        log(result!.code!);

        // getQrData(result!.code!).then((value) {
        //   if (value == true) {
        //     Get.back();
        //      addAttendance(date, result!.code!);

        //     Fluttertoast.cancel();
        //     Fluttertoast.showToast(
        //       msg: value.toString(),
        //       timeInSecForIosWeb: 3,
        //       toastLength: Toast.LENGTH_LONG,
        //       gravity: ToastGravity.BOTTOM,
        //       backgroundColor: Colors.red,
        //       textColor: Colors.white,
        //       fontSize: 16.0,
        //     );
        //   } else {
        //     Get.back();
        //     controller.resumeCamera();
        //     Fluttertoast.cancel();
        //     Fluttertoast.showToast(
        //       msg: "Invalid QR Code",
        //       timeInSecForIosWeb: 3,
        //       toastLength: Toast.LENGTH_LONG,
        //       gravity: ToastGravity.BOTTOM,
        //       backgroundColor: Colors.red,
        //       textColor: Colors.white,
        //       fontSize: 16.0,
        //     );
        //   }
        // });
      } else {
        Fluttertoast.cancel();
        controller.resumeCamera();
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

  addAttendance(String date, String value) async {
    final date = (DateTime.now().day < 10
            ? "0${DateTime.now().day}"
            : DateTime.now().day.toString()) +
        (DateTime.now().month < 10
            ? "0${DateTime.now().month}"
            : DateTime.now().month.toString()) +
        DateTime.now().year.toString();
    final isIncoming = await FirebaseFirestore.instance
        .collection("Users")
        .doc(value)
        .collection("Attendance")
        .doc(
          date,
        )
        .get()
        .then((value) => !value.exists);
    final data = await FirebaseFirestore.instance
        .collection("Users")
        .doc(value)
        .collection("Attendance")
        .doc(
          date,
        )
        .get();
    if (data.exists) {
      if (isIncoming) {
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
              .doc(value)
              .collection("Attendance")
              .doc(
                date,
              )
              .update({
            "outdateTime": DateTime.now().millisecondsSinceEpoch.toString(),
          });
          Provider.of<SoundController>(context, listen: false).outsoundPlay();

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
          .doc(value)
          .collection("Attendance")
          .doc(
            date,
          )
          .set(incomingData);
      Provider.of<SoundController>(context, listen: false).insoundPlay();

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
    controller!.resumeCamera();
  }

  getQrData(String value) async {
    final data =
        await FirebaseFirestore.instance.collection("Users").doc(value).get();
    return data.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NewHomePage'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }
}
