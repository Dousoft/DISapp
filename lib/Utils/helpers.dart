import 'package:flutter/material.dart';
import 'package:get/get.dart';

showLoader() {
  Get.dialog(
    WillPopScope(
      onWillPop: () async => true,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    ),
    barrierDismissible: false,
  );
}
