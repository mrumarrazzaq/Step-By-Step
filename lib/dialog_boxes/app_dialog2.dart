import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:stepbystep/colors.dart';

class AppDialog2 extends StatelessWidget {
  const AppDialog2({Key? key}) : super(key: key);

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
                  'What is Members Section?',
                  style: GoogleFonts.kanit(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Text(
                  """A member section is an essential feature that allows you to add, remove, and manage team members effectively. With this feature, you can create a team by adding members, assigning tasks to them, and tracking their progress. Additionally, you can assign customized roles and authorities to each member to ensure a smooth workflow.

Moreover, the member section offers advanced filtering options that allow you to filter members by their assigned roles, making it easier to track specific members' progress. You can also view the sub-teams of each member, making it easier to manage larger teams efficiently. By utilizing the member section, you can streamline your team management process and improve your team's overall productivity.""",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.titilliumWeb(),
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
                  'What is Roles Section?',
                  style: GoogleFonts.kanit(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Text(
                  """In the role section, you can create new roles for your team or select from pre-defined templates. You can also customize the roles' authorities to control the actions of each member in the team. Additionally, you can assign a color to each role for easy categorization and quick identification. This helps in streamlining the workflow and simplifying the management process. The color-coding feature makes it easy to differentiate between roles and quickly identify which members are assigned to which role. Furthermore, you can easily modify or remove roles, as well as manage the permissions for each role, providing greater flexibility and control over your team's operations.""",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.titilliumWeb(),
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
                  'What is View Section?',
                  style: GoogleFonts.kanit(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Text(
                  """The "View" section allows you to easily view the organization's team structure in a hierarchical manner, with a clear visualization of the reporting relationships and sub-teams within the organization.""",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.titilliumWeb(),
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
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            alignment: Alignment.center,
            backgroundColor: AppColor.transparent,
            content: Material(
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
                  'Close',
                  style: TextStyle(color: AppColor.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
