import 'package:flutter/material.dart';

class AppFutureBuilder extends StatefulWidget {
  AppFutureBuilder({Key? key, required this.future, required this.widget})
      : super(key: key);
  Future<String> future;
  Widget widget;

  @override
  State<AppFutureBuilder> createState() => _AppFutureBuilderState();
}

class _AppFutureBuilderState extends State<AppFutureBuilder> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Text('');
          default:
            if (snapshot.hasError) {
              return Container();
            } else {
              return widget.widget;
            }
        }
      },
    );
  }
}
