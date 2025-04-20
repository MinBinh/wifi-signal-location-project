import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import "../WifiData.dart";

/*  since the ouput of the model are numeric, the number index would
correspond to one of these named rooms or areas */

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Function used to funnel certain rooms where students meet teachers
  bool containsRoomWithNumber(String input) {
    RegExp regExp = RegExp(r'Room \d{4}');
    return regExp.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {

    final globalData = Provider.of<WifiData>(context);
    int predictNum = globalData.getPredictNum();
    String prediction = globalData.getPrediction();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flex Check-in'),
        // Back to Concordia App Main Screen
        leading: BackButton(
          // Back to App Main Screen of School App
          onPressed: () {
            SystemNavigator.pop();
          }
        )
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              alignment: Alignment.topRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  minimumSize: Size.fromRadius(40),
                  elevation: 10.0,
                ),
                onPressed: () {
                  //scan
                  Navigator.pushReplacementNamed(context, "/scan");
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 30,
                    ),
                    Text("Rescan", style: TextStyle(fontSize: 10))
                  ],
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 40.0),
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(350),
                  shape: CircleBorder(),
                  elevation: 10.0,
                ),
                onPressed: () {
                  globalData.updateFinalLocation(prediction);
                  if (!containsRoomWithNumber(globalData.getFinalLocation())){
                    Navigator.pushNamed(context, "/check");
                  } else{
                    Navigator.pushNamed(context, "/askteacher");
                  }
                  // //globalData.updateFinalLocation(prediction);
                  // if (!containsRoomWithNumber(globalData.getFinalLocation())){
                  //   //globalData.updateTeacher("");
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => Checkin()),
                  //   );
                  // } else{
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => IfMeetingTeacher()),
                  //   );
                  // }
                },
                child: Text('Check in\n'+prediction.toString(), textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30,),),
              ),
            ),

            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.center,
              children: WifiData.rooms[predictNum].sublist(1).map((item) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromRadius(50),
                    shape: CircleBorder(),
                    elevation: 10.0,
                  ),
                  onPressed: () {
                    globalData.updateFinalLocation(item);
                    if (!containsRoomWithNumber(globalData.getFinalLocation())){
                      Navigator.pushNamed(context, "/check");
                    } else{
                      Navigator.pushNamed(context, "/askteacher");
                    }
                    // //globalData.updateFinalLocation(item);
                    // if (!containsRoomWithNumber(globalData.getFinalLocation())){
                    //   //globalData.updateTeacher("");
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => Checkin()),
                    //   );
                    // } else{
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => IfMeetingTeacher()),
                    //   );
                    // }
                  },
                  child: Text("Check in\n"+item, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10,)),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
