import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

class Command {
  static final all = [appName, email, browser1, browser2];

  static const appName = 'Step By Step';
  static const email = 'write email';
  static const browser1 = 'open';
  static const browser2 = 'go to';
}

class Utils {
  static void scanText(String rawText) {
    log('Text is Scanning.....................');
    final text = rawText.toLowerCase();
    List<String> questions = [
      'purpose application',
      'need create workspace',
      'Who are you',
    ];
    List<String> answers = [
      'the application is design for manage the organizations so productivity will enhance',
      'You need to create workspace to handle members and task in the organization',
      'i am your assistant you can clear your queries by asking questions from me',
    ];

    for (int i = 0; i < questions.length; i++) {
      List<String> words = questions[i].split(' ');
      for (var word in words) {
        if (text.contains(word)) {
          log(answers[i].toString());
          break;
        }
      }
    }
    if (text.contains(Command.email)) {
      final body = _getTextAfterCommand(text: text, command: Command.email);

      openEmail(body: body);
    } else if (text.contains(Command.browser1)) {
      final url = _getTextAfterCommand(text: text, command: Command.browser1);

      openLink(url: url);
    } else if (text.contains(Command.browser2)) {
      final url = _getTextAfterCommand(text: text, command: Command.browser2);

      openLink(url: url);
    }
  }

  static String _getTextAfterCommand({
    required String text,
    required String command,
  }) {
    final indexCommand = text.indexOf(command);
    final indexAfter = indexCommand + command.length;

    if (indexCommand == -1) {
      return '';
    } else {
      return text.substring(indexAfter).trim();
    }
  }

  static Future openLink({
    required String url,
  }) async {
    if (url.trim().isEmpty) {
      await _launchUrl('https://google.com');
    } else {
      await _launchUrl('https://$url');
    }
  }

  static Future openEmail({
    required String body,
  }) async {
    final url = 'mailto: ?body=${Uri.encodeFull(body)}';
    await _launchUrl(url);
  }

  static Future _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
