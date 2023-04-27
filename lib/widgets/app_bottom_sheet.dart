import 'package:flutter/material.dart';

class MyBottomSheet extends StatelessWidget {
  const MyBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.83,
      maxChildSize: 0.83,
      minChildSize: 0.83,
      expand: true,
      builder: (context, scrollController) {
        return Container(
          color: Colors.transparent,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Text('Umar'),
          ),
        );
      },
    );
  }
}

// To show the bottom sheet, you can use the following code:
// showModalBottomSheet(
// backgroundColor: Colors.transparent,
// context: context,
// isScrollControlled: true,
// isDismissible: true,
// builder: (BuildContext context) {
// return const MyBottomSheet();
// },
// );
