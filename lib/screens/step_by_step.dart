import 'package:flutter/material.dart';
import 'package:stepbystep/screens/404_error.dart';

import 'package:stepbystep/screens/drawer.dart';
import 'package:stepbystep/screens/home.dart';
import 'package:stepbystep/screens/user_profile_section/user_profile.dart';

import 'package:stepbystep/visualization/visualization.dart';

class StepByStep extends StatefulWidget {
  const StepByStep({Key? key}) : super(key: key);

  @override
  State<StepByStep> createState() => _StepByStepState();
}

class _StepByStepState extends State<StepByStep> {
  int _currentIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    Container(),
    Container(),
    Container(),
    UserProfile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('logos/StepByStep(text).png', height: 22),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Visualization(
                    workspaceName: 'Workspace Name',
                    userName: 'User Email',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.mobile_friendly),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline_sharp),
            label: 'My Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
