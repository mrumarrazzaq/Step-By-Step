import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';

import 'package:dotted_line/dotted_line.dart';

class DetailedView extends StatefulWidget {
  const DetailedView({Key? key}) : super(key: key);

  @override
  State<DetailedView> createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CEO'),
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
              children: const [
                Root(),
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
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, left: 40.0),
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
          padding: const EdgeInsets.only(left: 32.0, top: 32),
          child: CircleAvatar(
            radius: 10,
            backgroundColor: AppColor.grey,
          ),
        ),
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColor.orange,
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
          padding: const EdgeInsets.only(top: 40, left: 40.0),
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
          padding: const EdgeInsets.only(left: 32.0, top: 30),
          child: CircleAvatar(
            radius: 10,
            backgroundColor: AppColor.grey,
          ),
        ),
        const Card(
          margin: EdgeInsets.only(left: 80, bottom: 10, top: 10, right: 10),
          child: ListTile(
            title: Text('Umar'),
          ),
        ),
      ],
    );
  }
}
