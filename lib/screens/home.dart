import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:stepbystep/colors.dart';

import 'package:stepbystep/screens/self_task_manager/selfspace_home.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size(0, -8),
            child: TabBar(
              unselectedLabelColor: AppColor.black,
              labelColor: AppColor.orange,
              labelStyle:
                  GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.roboto(fontSize: 20),
              indicatorColor: AppColor.transparent,
              tabs: const [
                Tab(
                  text: 'Selfspace',
                ),
                Tab(
                  text: 'Workspace',
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            SelfSpaceHome(),
            WorkspaceHome(),
          ],
        ),
      ),
    );
  }
}
