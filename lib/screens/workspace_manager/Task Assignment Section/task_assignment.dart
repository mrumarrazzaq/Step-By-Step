import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';

class TaskAssignment extends StatefulWidget {
  @override
  _TaskAssignmentState createState() => _TaskAssignmentState();
}

class _TaskAssignmentState extends State<TaskAssignment> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size(0, -8),
            child: Container(
              color: AppColor.black,
              child: TabBar(
                indicatorColor: Colors.transparent,
                unselectedLabelColor: AppColor.white,
                labelColor: AppColor.orange,
                tabs: const [
                  Tab(
                    child: Text('TODO'),
                  ),
                  Tab(
                    child: Text('Doing'),
                  ),
                  Tab(
                    child: Text('Review'),
                  ),
                  Tab(
                    child: Text('Completed'),
                  ),
                  Tab(
                    child: Text('Expired'),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Material(
          borderRadius: const BorderRadius.all(Radius.circular(30.0)),
          clipBehavior: Clip.antiAlias,
          child: MaterialButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    title: Center(
                      child: Text(
                        'Assign Task',
                        style: TextStyle(
                            color: AppColor.grey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          style: const TextStyle(),
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Task Title',
                            hintText: 'Enter Task Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          style: const TextStyle(),
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Due Date',
                            hintText: 'Enter Due Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Material(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30.0)),
                          clipBehavior: Clip.antiAlias,
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            color: AppColor.orange,
                            child: Text(
                              'Assign',
                              style: TextStyle(
                                  color: AppColor.white, fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            color: AppColor.orange,
            child: Text(
              'Assign Task',
              style: TextStyle(color: AppColor.white, fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  String title;
  String email;
  String date;

  TaskTile(
      {Key? key, required this.title, required this.email, required this.date})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: ListTile(
        dense: true,
        title: Padding(
          padding: const EdgeInsets.only(left: 50.0),
          child: Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColor.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 50.0),
          child: Column(
            children: [
              Text(
                email,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColor.grey,
                ),
              ),
              Text(
                date,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColor.grey,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.ac_unit),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
