import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class MessageNotificationApi {
  static void send(
      {required String token,
      required String title,
      required String body}) async {
    try {
      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization":
            "key=AAAAv53WdXs:APA91bEZ5rE5Ui-zpNlfwyRZ0F3stj3Jh56nh9VneCRyICDdK92eepiOUfnDauzpLJ9hnrZoPQfN_xj1KAobpLJUc4-cu0CKWZ91TtEj-A4yPObDAqaXgI5s3ozTnmEylA3aq8SaQIbq"
      };
      String url = 'https://fcm.googleapis.com/fcm/send';
      String requestBody = jsonEncode({
        "registration_ids": [token],
        "notification": {
          "body": body,
          "title": title,
          "android_channel_id": "stepbystep",
          "sound": false
        }
      });
      final response = await http.post(
        Uri.parse(url),
        body: requestBody,
        headers: headers,
      );
      if ((response.statusCode == 200 || response.statusCode == 201)) {
        log('الحمداللہ الحمداللہ الحمداللہ');
      }
    } catch (e) {
      log('Failed to send message notification');
    }
  }
}
