import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "../WifiData.dart";

class TeacherSelect extends StatelessWidget {
  const TeacherSelect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final globalData = Provider.of<WifiData>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flex Check-in'),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          }
        )
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Text("Who are you meeting with?", style: TextStyle(fontSize: 20)),
              margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            ),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.center,
              children: WifiData.teachers.map((item) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(130, 50), // Set a fixed size
                    elevation: 10.0,
                  ),
                  onPressed: () {
                    // record item (teacher name)
                    globalData.updateTeacher(item);
                    // go to checkin
                    Navigator.pushNamed(context, "/check");
                  },
                  child: Text(item, textAlign: TextAlign.center),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}