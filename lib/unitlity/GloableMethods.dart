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

String durationToString(Duration duration) {
  String makeTwoDigits(int i) {
    return "${i > 9 ? i : "0$i"}";
  }

  String s = "";
  if (duration.inHours > 0) {
    s += "${makeTwoDigits(duration.inHours)}:";
  }
  if ((duration.inMinutes % 60) > 0 || duration.inHours > 0) {
    s += "${makeTwoDigits(duration.inMinutes % 60)}:";
  } else {
    s += "00:";
  }
  if ((duration.inSeconds % 60) > 0 ||
      (duration.inMinutes % 60) > 0 ||
      duration.inHours > 0) {
    s += "${makeTwoDigits(duration.inSeconds % 60)}";
  } else {
    s += "00";
  }
  return s;
}
