import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gesturecontrollers/screens/VideoList/video_list.dart';
import 'package:gesturecontrollers/screens/player/media_player.dart';
import 'package:gesturecontrollers/unitlity/GloableMethods.dart';
import 'package:gesturecontrollers/unitlity/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: colorBackGround,
      statusBarColor: colorBackGround,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0288FE),
            background: const Color(0xFF16202A),
            primary: const Color(0xFF0288FE)),
        useMaterial3: true,
      ),
      home: const Master(),
    );
  }
}

class Master extends StatefulWidget {
  const Master({super.key});

  @override
  State<Master> createState() => _MasterState();
}

class _MasterState extends State<Master> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      appBar: AppBar(),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const VideoList();
                  },
                ));
              },
              child: const Text("List"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return MediaPlayer(path: "https://master8blaster.000webhostapp.com/2675c70c-ba45-4ecd-9d57-13586f13e871%20(1).mp4",);
                  },
                ));
              },
              child: const Text("Next"),
            ),
            TextButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? galleryVideo =
                    await picker.pickVideo(source: ImageSource.gallery);
                if (galleryVideo != null &&
                    await File(galleryVideo.path).exists()) {
                  Directory appDirectory =
                      await getApplicationDocumentsDirectory();
                  Directory hiddenVideoDirectory =
                      await Directory("${appDirectory.path}/.videos").create();
                  File file = await File(galleryVideo!.path)
                      .copy(
                          "${hiddenVideoDirectory.path}/${galleryVideo.path.split("/").last}")
                      .then((value) async {
                    print(value.path);

                    return value;
                  });
                  print("FILE WRITE DONE ${file.path}");
                  if (await file.exists()) {
                    await File(galleryVideo.path).delete();
                  }
                  print("FILE Deleted ${file.path}");
                } else {
                  showSnackBarWithText(_keyScaffold.currentState,
                      "We can't find any video file in selection!");
                }
              },
              child: const Text("Secure Folder"),
            ),
          ],
        ),
      ),
    );
  }
}

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // brightness variables
//   double brightness = 0.5;
//   double previousBrightness = 0.5;
//   double yBrightness = 0.0;

//   // volume controller variables
//   double volume = 0.5;
//   double previousVolume = 0.5;
//   double yVolume = 0.0;

//   //video Player Variables

//   BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.network,"https://vod-progressive.akamaized.net/exp=1698148120~acl=%2Fvimeo-prod-skyfire-std-us%2F01%2F3064%2F18%2F465324323%2F2064061118.mp4~hmac=949d84b089b9840450761fe0829ad480f68d7e5404c3c1ca7b599041e17f2f07/vimeo-prod-skyfire-std-us/01/3064/18/465324323/2064061118.mp4?download=1&amp;filename=pexels-thirdman-5538137+%281080p%29.mp4");
//    BetterPlayerController _betterPlayerController =  _betterPlayerController = BetterPlayerController(
//         BetterPlayerConfiguration(),
//         betterPlayerDataSource: betterPlayerDataSource);
//   // BetterPlayerController _betterPlayerController = VideoPlayerController.networkUrl(Uri.parse(
//   //     "https://vod-progressive.akamaized.net/exp=1698148120~acl=%2Fvimeo-prod-skyfire-std-us%2F01%2F3064%2F18%2F465324323%2F2064061118.mp4~hmac=949d84b089b9840450761fe0829ad480f68d7e5404c3c1ca7b599041e17f2f07/vimeo-prod-skyfire-std-us/01/3064/18/465324323/2064061118.mp4?download=1&amp;filename=pexels-thirdman-5538137+%281080p%29.mp4"));
//   bool isVideoPlaying = false;
//   Duration videoDuration = const Duration();
//   double duration = 0.5;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getVolume();
//     controller.initialize().then((value) => setState(() {
//           controller.play();
//           controller.addListener(() {
//             setState(() {});
//           });
//           controller.setLooping(true);
//         }));

//     isVideoPlaying = true;
//     ScreenBrightness().hasChanged.then((value) async {
//       brightness = await ScreenBrightness().current;
//       setState(() {});
//     });
//   }

//   getVolume() async {
//     previousVolume = await VolumeController().getVolume();
//     volume = previousVolume;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           _buildControllerExpanded(),
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 if (isVideoPlaying) {
//                   controller.pause();
//                   isVideoPlaying = false;
//                 } else {
//                   controller.play();
//                   isVideoPlaying = true;
//                 }
//                 print("isVideoPlaying = $isVideoPlaying");
//               },
//               child: Center(
//                 child: AspectRatio(
//                   aspectRatio: controller.value.aspectRatio,
//                   child: VideoPlayer(
//                     controller,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Row(
//             children: [
//               Text(
//                   "${controller.value.position.inHours}:${controller.value.position.inMinutes}:${controller.value.position.inSeconds}"),
//               Expanded(
//                 child: Slider(
//                   min: 0,
//                   max: controller.value.duration.inMilliseconds.toDouble(),
//                   value: controller.value.position.inMilliseconds.toDouble(),
//                   onChanged: (double value) {
//                     controller.seekTo(Duration(milliseconds: value.toInt()));
//                     controller.play();
//                   },
//                 ),
//               ),
//               Text(
//                   "${controller.value.duration.inHours}:${controller.value.duration.inMinutes}:${controller.value.duration.inSeconds}"),
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Future<double> get currentBrightness async {
//     try {
//       return await ScreenBrightness().current;
//     } catch (e) {
//       print(e);
//       throw 'Failed to get current brightness';
//     }
//   }

//   Widget _buildControllerExpanded() {
//     return Expanded(
//       child: Row(
//         children: [
//           Expanded(
//             child: GestureDetector(
//               onPanDown: (data) {
//                 yBrightness = data.globalPosition.dy;
//               },
//               onPanUpdate: (data) {
//                 double d = previousBrightness +
//                     ((yBrightness - data.globalPosition.dy) / 100);
//                 if (d > 0 && d < 1) {
//                   brightness = d;
//                 } else if (d < 0) {
//                   brightness = 0;
//                 } else if (d > 1) {
//                   brightness = 1;
//                 }
//                 print(brightness);
//                 setBrightness(brightness);

//                 setState(() {});
//               },
//               onPanEnd: (details) {
//                 previousBrightness = brightness;
//               },
//               child: Container(
//                 color: Colors.yellow,
//                 child: Center(
//                   child: Container(
//                     height: 100,
//                     // width: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(2),
//                       border: Border.all(
//                         color: Colors.black,
//                         width: 1,
//                       ),
//                     ),
//                     child: FAProgressBar(
//                       direction: Axis.vertical,
//                       animatedDuration: const Duration(milliseconds: 100),
//                       border: Border.all(color: Colors.white, width: 1),
//                       currentValue: brightness * 100,
//                       backgroundColor: Colors.white,
//                       borderRadius: BorderRadius.circular(2),
//                       formatValue: (value, fixed) {
//                         return (brightness * 10).toInt().toString();
//                       },
//                       formatValueFixed: 100,
//                       progressColor: Colors.lightBlueAccent,
//                       changeProgressColor: Colors.lightBlueAccent,
//                       displayText: (brightness * 0).toInt().toString(),
//                       maxValue: 100,
//                       verticalDirection: VerticalDirection.up,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: GestureDetector(
//               onPanDown: (data) {
//                 yVolume = data.globalPosition.dy;
//               },
//               onPanUpdate: (data) {
//                 double d =
//                     previousVolume + ((yVolume - data.globalPosition.dy) / 100);
//                 if (d > 0 && d < 1) {
//                   volume = d;
//                 } else if (d < 0) {
//                   volume = 0;
//                 } else if (d > 1) {
//                   volume = 1;
//                 }
//                 print(volume);
//                 VolumeController().setVolume(volume);

//                 setState(() {});
//               },
//               onPanEnd: (details) {
//                 previousVolume = volume;
//               },
//               child: Container(
//                 color: Colors.red,
//                 child: Center(
//                   child: Container(
//                     height: 100,
//                     // width: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(2),
//                       border: Border.all(
//                         color: Colors.black,
//                         width: 1,
//                       ),
//                     ),
//                     child: FAProgressBar(
//                       direction: Axis.vertical,
//                       animatedDuration: const Duration(milliseconds: 100),
//                       border: Border.all(color: Colors.white, width: 1),
//                       currentValue: volume * 100,
//                       backgroundColor: Colors.white,
//                       borderRadius: BorderRadius.circular(2),
//                       formatValue: (value, fixed) {
//                         return (volume * 10).toInt().toString();
//                       },
//                       formatValueFixed: 100,
//                       progressColor: Colors.lightBlueAccent,
//                       changeProgressColor: Colors.lightBlueAccent,
//                       displayText: (volume * 0).toInt().toString(),
//                       maxValue: 100,
//                       verticalDirection: VerticalDirection.up,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> setBrightness(double brightness) async {
//     try {
//       await ScreenBrightness().setScreenBrightness(brightness);
//     } catch (e) {
//       print(e);
//       throw 'Failed to set brightness';
//     }
//   }
// }
