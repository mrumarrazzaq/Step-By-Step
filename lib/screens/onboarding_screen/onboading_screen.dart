import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/security_section/registeration_screen2.dart';
import 'package:stepbystep/screens/security_section/registration_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  static const String id = 'OnBoardingScreen';
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final _pageController = PageController();
  bool isLastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 60),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == 2;
            });
          },
          children: [
            //SCREEN No 1
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('animations/remote_management.json',
                        repeat: false),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text: '"Take control of your organization ',
                              style: GoogleFonts.robotoMono(),
                            ),
                            TextSpan(
                              text: 'remotely ',
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'with our app."',
                              style: GoogleFonts.robotoMono(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //SCREEN No 2
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('animations/data_protection.json',
                        repeat: true, width: 300),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 30.0),
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text: '"Our hierarchical ',
                              style: GoogleFonts.robotoMono(),
                            ),
                            TextSpan(
                              text:
                                  'team management, task assignment, role assignment ',
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: 'and ',
                              style: GoogleFonts.robotoMono(),
                            ),
                            TextSpan(
                              text: 'progress tracking ',
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'features provide complete control, allowing you to optimize productivity and drive growth."',
                              style: GoogleFonts.robotoMono(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //SCREEN No 3
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('animations/data-management.json',
                        repeat: true, width: 250),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 60.0),
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text:
                                  'Get started today and take your business to the ',
                              style: GoogleFonts.robotoMono(),
                            ),
                            TextSpan(
                              text: 'next level!',
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: isLastPage
          ? MaterialButton(
              color: AppColor.orange,
              height: 60,
              minWidth: double.infinity,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationScreen2(),
                  ),
                );
              },
              child: Text(
                'Get Started',
                style: TextStyle(fontSize: 20, color: AppColor.white),
              ))
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _pageController.jumpToPage(2);
                    },
                    child: Text(
                      'SKIP',
                      style: TextStyle(color: AppColor.black),
                    ),
                  ),
                  Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: 3,
                      onDotClicked: (index) {
                        _pageController.animateToPage(index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      effect: WormEffect(
                        activeDotColor: AppColor.orange,
                        dotColor: AppColor.grey,
                        dotHeight: 12.0,
                        dotWidth: 12.0,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                    },
                    child: Text(
                      'NEXT',
                      style: TextStyle(color: AppColor.black),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
