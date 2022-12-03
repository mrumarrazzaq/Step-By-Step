import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stepbystep/providers/date_comparison.dart';
import 'package:stepbystep/providers/taskCollection.dart';
import 'package:stepbystep/providers/silence_operations.dart';

import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:stepbystep/screens/myapp.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  log('APP ROOT MAIN IS IN RUNNING');
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
