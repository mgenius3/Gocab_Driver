import 'package:flutter/material.dart';
import 'package:Driver/app/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:Driver/services/auth.dart';
import 'package:Driver/splash.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'infoHandler/app_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'localNotifications/notification_service.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(GoAppDriver());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// background handler
Future backgroundHandler(RemoteMessage msg) async {}

class GoAppDriver extends StatefulWidget {
  const GoAppDriver({Key? key}) : super(key: key);

  @override
  _GoAppDriverState createState() => _GoAppDriverState();
}

class _GoAppDriverState extends State<GoAppDriver> {
  late MaterialColor customPrimarySwatch;

  LocationPermission? _locationPermission;
  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    LocalNotificationService.initialize(flutterLocalNotificationsPlugin);
    customPrimarySwatch = MaterialColor(
      0xFF0D47A1,
      <int, Color>{
        50: Color(0xFFE3F2FD),
        100: Color(0xFFBBDEFB),
        200: Color(0xFF90CAF9),
        300: Color(0xFF64B5F6),
        400: Color(0xFF42A5F5),
        500: Color(0xFF2196F3),
        600: Color(0xFF1E88E5),
        700: Color(0xFF1976D2),
        800: Color(0xFF1565C0),
        900: Color(0xFF0D47A1),
        // 900: Color(0xFFFF4500)
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'GoCab Driver',
        theme: ThemeData(
          primarySwatch: customPrimarySwatch,
        ),
        debugShowCheckedModeBanner: false,
        home: Splash(),
      ),
    );
  }
}
