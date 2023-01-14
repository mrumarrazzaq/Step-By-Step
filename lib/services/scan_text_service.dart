import 'dart:developer';

class ScanText {
  static String scan(String rawText) {
    log('Text is Scanning.....................');
    final text = rawText.toLowerCase();
    String reply = '';
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
    // for (var key in botData.keys) {
    //   log('$text                      $key');
    //   if (text.toString() == key.toString()) {
    //     print('botData[key]');
    //   }
    // }

    for (int i = 0; i < questions.length; i++) {
      List<String> words = questions[i].split(' ');
      for (var word in words) {
        if (text.contains(word)) {
          reply = answers[i];
          break;
        }
      }
    }
    if (reply.isEmpty) {
      reply = 'Sorry i can not understand your question?';
    }
    return reply;
  }
}
