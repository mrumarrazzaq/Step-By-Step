import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/colors.dart';
import 'package:dotted_line/dotted_line.dart';

class DetailedView extends StatefulWidget {
  DetailedView(
      {Key? key,
      required this.workspaceName,
      required this.workspaceCode,
      required this.role,
      required this.level})
      : super(key: key);
  String workspaceCode;
  String workspaceName;
  String role;
  int level;
  @override
  State<DetailedView> createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.workspaceName,
          style:
              TextStyle(color: AppColor.darkGrey, fontWeight: FontWeight.w900),
        ),
        backgroundColor: AppColor.white,
        bottom: PreferredSize(
          preferredSize: const Size(30, 50),
          child: Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 5.0),
            width: double.infinity,
            color: AppColor.black,
            child: Center(
              child: Text(
                'Level ${widget.level}',
                style: GoogleFonts.inconsolata(
                    color: AppColor.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 40.0),
              child: DottedLine(
                direction: Axis.vertical,
                lineLength: double.infinity,
                lineThickness: 5.0,
                dashLength: 8.0,
                dashColor: Colors.black,
                dashGradient: [AppColor.grey, AppColor.grey],
                dashRadius: 0.0,
                dashGapLength: 7.0,
                dashGapColor: Colors.transparent,
                dashGapGradient: [AppColor.transparent, AppColor.transparent],
                dashGapRadius: 0.0,
              ),
            ),
            ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Root(role: widget.role),
                Connector(),
                Connector(),
                Connector(),
                Connector(),
                Connector(),
                Connector(),
                Connector(),
                Connector(),
                Connector(),
                Connector(),
                Connector(),
                Connector(),
                Connector(),
                Connector(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Root extends StatelessWidget {
  Root({Key? key, required this.role}) : super(key: key);
  String role;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 55, left: 40.0),
          child: DottedLine(
            direction: Axis.horizontal,
            lineLength: MediaQuery.of(context).size.width / 2,
            lineThickness: 5.0,
            dashLength: 8.0,
            dashColor: Colors.black,
            dashGradient: [AppColor.grey, AppColor.grey],
            dashRadius: 0.0,
            dashGapLength: 7.0,
            dashGapColor: Colors.transparent,
            dashGapGradient: [AppColor.transparent, AppColor.transparent],
            dashGapRadius: 0.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 48),
          child: CircleAvatar(
            radius: 10,
            backgroundColor: AppColor.grey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColor.orange,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 120.0),
          child: Center(
            child: Text(
              role,
              style: GoogleFonts.kanit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Connector extends StatelessWidget {
  const Connector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 48, left: 40.0),
          child: DottedLine(
            direction: Axis.horizontal,
            lineLength: double.infinity,
            lineThickness: 5.0,
            dashLength: 8.0,
            dashColor: Colors.black,
            dashGradient: [AppColor.grey, AppColor.grey],
            dashRadius: 0.0,
            dashGapLength: 7.0,
            dashGapColor: Colors.transparent,
            dashGapGradient: [AppColor.transparent, AppColor.transparent],
            dashGapRadius: 0.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 40),
          child: CircleAvatar(
            radius: 10,
            backgroundColor: AppColor.grey,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Card(
            margin:
                const EdgeInsets.only(left: 80, bottom: 10, top: 10, right: 10),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColor.orange, width: 20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: CircleAvatar(
                        backgroundColor: AppColor.orange.withOpacity(0.2),
                        radius: 32,
                      ),
                    ),
                    const Text(
                      'Person Name',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Lottie.asset(
                        repeat: false, height: 30, 'animations/graph.json'),
                  ],
                ),
              ),
            ),

            // ListTile(
            //   minLeadingWidth: 0,
            //   leading: CircleAvatar(radius: 30, backgroundColor: AppColor.orange),
            //   title: Text(
            //     'Umar',
            //     style: TextStyle(fontWeight: FontWeight.bold),
            //   ),
            // ),
          ),
        ),
      ],
    );
  }
}
