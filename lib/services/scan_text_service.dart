import 'dart:developer';

class ScanText {
  static String scan(String rawText) {
    log('Text is Scanning.....................');
    final text = rawText.toLowerCase();
    String reply = '';
    List<String> questions = [
      'purpose application',
      'what is self space',
      'what is workspace',
      'need create workspace',
      'Who are you',
      'Who is your creator',
      'Who is your team',
      'What is app uniqueness',
      'Who are we',
      'Our Vision',
      'Our Mission',
      'What are the business benefits of your app',
      'How Enhanced productivity by using your app',
      'How Increased revenue by using your app',
      'How Better organization by using your app',
      'How Better accountability by using your app',
      'How Improve Communication by using your app',
      'How Improve Collaboration by using your app',
      'How Improved performance by using your app',
      'How Increase Success Rates by using your app',
    ];
    List<String> answers = [
      //app purpose
      'the application is design for manage the organizations so productivity will enhance',
      //what is self space
      'A self-space is a personalized virtual environment that allows you to efficiently manage your daily tasks and improve your productivity. You can customize your self-space to reflect your individual needs and preferences, adding tools and resources that help you stay organized and focused. Additionally, you can link your self-space to your workspace and collaborate with others by assigning tasks and sharing information. With a self-space, you have the flexibility to tailor your workflow to suit your unique working style and optimize your productivity.',
      //what is workspace
      """A workspace is a digital environment where you can organize and manage your team's tasks and projects. Think of it as a virtual office where team members can collaborate, communicate, and work together to achieve common goals.

When you create a workspace, you give it a name and a type, which is typically based on the type of work your team does. For example, you might create a workspace for software development, marketing, or customer support.

Once you've set up your workspace, you can invite team members to join and assign them specific roles and responsibilities. You can also create sub-teams within the workspace to focus on specific projects or tasks.

By centralizing your team's work within a workspace, you can streamline communication, reduce confusion, and ensure that everyone is working towards the same objectives. Additionally, many workspace tools offer features such as task tracking, file sharing, and team calendars to help you stay organized and focused on your goals.""",
      //need create workspace
      'You need to create workspace to handle members and task in the organization',
      //Who are you
      'i am your assistant you can clear your queries by asking questions from me',
      //Who is your creator
      'Umar Razzaq is developer who develop me',
      //Who is your team
      'My team is Team Alpha',
      //What is app uniqueness
      'This app is unique because it focuses on organization management rather than project management. As an organization controller, your role is to manage the capacity of your organization and ensure efficient handling of teams and tasks. This app provides you with complete control over your organization, allowing you to manage your teams and tasks with ease. Its features are specifically designed to help you streamline your organizations workflow and maximize efficiency.',
      //Who are we
      'We are solution providers. We believe in simplifying complex processes and providing user-friendly tools that can streamline workflows and maximize outputs.',
      //Our Vision
      'Our vision is to enhance productivity around the world by implementing efficient solutions and promoting effective work practices.',
      //Our Mission
      'Our mission is to empower individuals and organizations to work smarter, not harder, and to create a more productive and prosperous global community.',

      //What are the business benefits of your app
      'Enhanced productivity  Increased revenue  Better organization   Better accountability  Improve Communication  Improve Collaboration   Improved performance  Increase Success Rates',

      'The app’s team management, task assignment, and role assignment features can help businesses and entrepreneurs improve productivity and efficiency within the organization by ensuring that tasks are completed on time and to the desired level of quality.',

      'By improving productivity and efficiency, businesses can complete tasks more quickly and effectively, leading to increased revenue and profitability.',

      'The hierarchical structure of the app ensures clear lines of responsibility and communication, making it easier to delegate tasks.',

      'The app’s hierarchical structure ensures clear lines of responsibility making it easier to team members accountable for their roles and responsibilities.',

      'The app’s team management feature allows the user to create and manage multiple teams within the organization, improving communication.',

      'The app’s team management feature enables users to create and manage multiple teams within the organization, promoting better collaboration among team members.',

      'The app’s comprehensive system for managing an organization can help businesses and entrepreneurs improve their overall performance by providing a structured and efficient way to manage their teams and tasks.',

      'Effective management of key factors such as productivity, communication, revenue, and accountability can significantly increase business success. The app’s features for team and task management contribute to achieving these factors.',
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
