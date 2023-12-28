import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

Future<bool> isInterConnected() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}


showSnackBarWithText(ScaffoldState? scaffoldState, String strText,
    {Color color = Colors.redAccent,
      int duration = 2,
      void Function()? onPressOfOk}) {
  final snackBar = SnackBar(
    // behavior: SnackBarBehavior.floating,
    backgroundColor: color,
    content: Text(
      strText,
      style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins'),
    ),
    action: SnackBarAction(
      label: 'OK',
      textColor: Colors.white,
      onPressed: onPressOfOk ?? () {},
    ),
    duration: Duration(seconds: duration),
  );
  if (scaffoldState != null && scaffoldState.context != null) {
    ScaffoldMessenger.of(scaffoldState.context).showSnackBar(snackBar);
  }
}
