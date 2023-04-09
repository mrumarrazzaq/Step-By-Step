import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

class LaunchURLAPI {
  static Future<void> launchMyUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    } else {
      log('URL Launch Successfully');
    }
  }
}
