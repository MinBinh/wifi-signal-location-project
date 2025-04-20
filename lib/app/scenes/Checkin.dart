import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:provider/provider.dart";
import '../WifiData.dart';
import 'dart:developer' as logDev;
import 'package:gsheets/gsheets.dart';

class Checkin extends StatefulWidget {
  const Checkin({Key? key}) : super(key: key);

  @override
  State<Checkin> createState() => _MyAppState();
}

class _MyAppState extends State<Checkin> {
  var gsheets = GSheets(r'''{
    credential json paste here
  }''');
  late var spreadsheet;
  late var sheet;
  //Link to Spreadsheet
  var _spreadsheetId = '----speadsheet Id Go Here----';
  late var data;

  void RecordSpreadSheets(time, account, finalLocation, prediction, teacher) async{
    spreadsheet = await gsheets.spreadsheet(_spreadsheetId);
    sheet = await spreadsheet.worksheetByTitle("Sheet1");

    data = [time, account, finalLocation, prediction, teacher];

    await sheet.values.appendRow(data);
    logDev.log(data.toString(),name:"Row added");
  }

  @override
  Widget build(BuildContext context) {

    final globalData = Provider.of<WifiData>(context);

    // Sends to a spreadsheet:
    RecordSpreadSheets(globalData.getTime().toString(),"test",globalData.getFinalLocation().toString(),globalData.getPrediction().toString(),globalData.getTeacher().toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flex Check-in'),
        leading: BackButton(
          // Back to App Main Screen of School App
          onPressed: () {
            SystemNavigator.pop();
          }
        )
      ),
      body: Center(
        child: Container (
          height: 350,
          width: 350,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.lightGreenAccent,),
          child: Column (
            mainAxisAlignment: MainAxisAlignment.center,
            children : [
              Icon(
                Icons.check,
                size: 80,
              ),
              Text("Checked into "+globalData.getFinalLocation(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      )
    );
  }
}