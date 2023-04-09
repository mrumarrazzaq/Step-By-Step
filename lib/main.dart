import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stepbystep/notificationservice/local_notification_service.dart';
import 'package:stepbystep/providers/date_comparison.dart';
import 'package:stepbystep/providers/taskCollection.dart';
import 'package:stepbystep/providers/silence_operations.dart';

import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:stepbystep/screens/myapp.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> backgroundHandler(RemoteMessage message) async {
  log(message.data.toString());
  log(message.notification!.title.toString());
}

void main() async {
  log('APP ROOT MAIN IS IN RUNNING');
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  // await dotenv.load(fileName: "assets/.env");

  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskCollection(),
        ),
        ChangeNotifierProvider(
          create: (_) => DateCompare(),
        ),
        ChangeNotifierProvider(
          create: (_) => SilenceOperation(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
