import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class SendEmailAPI {
  Future sendEmail({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    const serviceId = 'service_ggdv28h';
    const templateId = 'template_fqzs2p9';
    const userId = '_7oDZVlR-KL2XvLAr';
    const accessToken = 'mamzcHY1BElA7jysjcIyX';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'accessToken': accessToken,
        'template_params': {
          'user_name': name,
          'user_email': email,
          'user_subject': subject,
          'user_message': message,
        },
      }),
    );
    log('------------------------------------');
    log('Email send successfully ${response.body}');
    log('------------------------------------');
  }
}
