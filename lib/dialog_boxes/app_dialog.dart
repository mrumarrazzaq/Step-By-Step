import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:stepbystep/colors.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            alignment: Alignment.center,
            backgroundColor: AppColor.lightOrange,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'What is Selfspace?',
                  style: GoogleFonts.kanit(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Text(
                  """A self-space is a personalized virtual environment that allows you to efficiently manage your daily tasks and improve your productivity. You can customize your self-space to reflect your individual needs and preferences, adding tools and resources that help you stay organized and focused. Additionally, you can link your self-space to your workspace and collaborate with others by assigning tasks and sharing information. With a self-space, you have the flexibility to tailor your workflow to suit your unique working style and optimize your productivity.""",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.titilliumWeb(),
                ),
                const SizedBox(height: 12.0),
                Material(
                  color: AppColor.orange,
                  borderRadius: BorderRadius.circular(10.0),
                  clipBehavior: Clip.antiAlias,
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    height: 40,
                    minWidth: double.infinity,
                    color: AppColor.orange,
                    elevation: 0.0,
                    child: Text(
                      'Learn More',
                      style: TextStyle(color: AppColor.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            alignment: Alignment.center,
            backgroundColor: AppColor.lightOrange,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'What is Workspace?',
                  style: GoogleFonts.kanit(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Text(
                  """A workspace is a digital environment where you can organize and manage your team's tasks and projects. Think of it as a virtual office where team members can collaborate, communicate, and work together to achieve common goals.

When you create a workspace, you give it a name and a type, which is typically based on the type of work your team does. For example, you might create a workspace for software development, marketing, or customer support.

Once you've set up your workspace, you can invite team members to join and assign them specific roles and responsibilities. You can also create sub-teams within the workspace to focus on specific projects or tasks.

By centralizing your team's work within a workspace, you can streamline communication, reduce confusion, and ensure that everyone is working towards the same objectives. Additionally, many workspace tools offer features such as task tracking, file sharing, and team calendars to help you stay organized and focused on your goals.""",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.titilliumWeb(),
                ),
                const SizedBox(height: 12.0),
                Material(
                  color: AppColor.orange,
                  borderRadius: BorderRadius.circular(10.0),
                  clipBehavior: Clip.antiAlias,
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    height: 40,
                    minWidth: double.infinity,
                    color: AppColor.orange,
                    elevation: 0.0,
                    child: Text(
                      'Learn More',
                      style: TextStyle(color: AppColor.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
