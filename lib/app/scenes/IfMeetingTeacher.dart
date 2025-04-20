import 'package:flutter/material.dart';

class IfMeetingTeacher extends StatelessWidget {
  const IfMeetingTeacher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: const Text('Flex Check-in'),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            }
          )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 40.0),
                alignment: Alignment.center,
                child: Text("Are You Meeting a Teacher?"),
            ),

            ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 10.0,),
                onPressed: () {
                  Navigator.pushNamed(context, "/check");
                },
                child: Text("No")),
            ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 10.0,),
                onPressed: () {
                  Navigator.pushNamed(context, "/teacherselect");
                }, child: Text("Yes")
            ),
          ]
        )
      )
    );
  }
}