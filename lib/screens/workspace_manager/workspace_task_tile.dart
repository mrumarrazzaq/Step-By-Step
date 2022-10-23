import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';

class WorkspaceTaskTile extends StatelessWidget {
  String title;
  String description;
  String email;
  String date;
  Color color;
  Function() leftFunction;
  Function() rightFunction;
  bool leftButton;
  bool rightButton;
  WorkspaceTaskTile({
    Key? key,
    required this.title,
    required this.description,
    required this.email,
    required this.date,
    required this.color,
    required this.leftFunction,
    required this.rightFunction,
    required this.leftButton,
    required this.rightButton,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Task Title      :  ',
                  style: TextStyle(
                    color: AppColor.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: title,
                  style: TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Assigned By :  ',
                  style: TextStyle(
                    color: AppColor.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: email,
                  style: TextStyle(
                    color: AppColor.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Due Date       :  ',
                  style: TextStyle(
                    color: AppColor.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: date,
                  style: TextStyle(
                    color: AppColor.white,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: leftButton,
                child: IconButton(
                  onPressed: leftFunction,
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              Visibility(
                visible: rightButton,
                child: IconButton(
                  onPressed: rightFunction,
                  icon: const Icon(
                    Icons.arrow_forward,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    //   Card(
    //   shape: RoundedRectangleBorder(
    //     side: BorderSide(color: color, width: 1),
    //     borderRadius: BorderRadius.circular(10),
    //   ),
    //   child: ListTile(
    //     dense: true,
    //     title: Text(
    //       title,
    //       textAlign: TextAlign.left,
    //       style: TextStyle(
    //         color: AppColor.darkGrey,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     subtitle: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           email,
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             color: AppColor.grey,
    //           ),
    //         ),
    //         Text(
    //           date,
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             color: AppColor.grey,
    //           ),
    //         ),
    //       ],
    //     ),
    //     trailing: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Visibility(
    //           visible: true,
    //           child: IconButton(
    //             onPressed: function,
    //             icon: const Icon(
    //               Icons.arrow_forward,
    //             ),
    //           ),
    //         ),
    //         Visibility(
    //           visible: true,
    //           child: IconButton(
    //             onPressed: function,
    //             icon: const Icon(Icons.arrow_back),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
