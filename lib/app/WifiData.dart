import 'package:flutter/material.dart';

class WifiData extends ChangeNotifier {
  late int predictNum;
  late String prediction;
  late String finalLocation;
  late String time;
  String teacher = "";

  // List of Bssids to organise string of wifi data
  static const List<String> bssids = ['0a:7b:c8:a8:9d:d5', '0a:7b:c8:a9:4d:96', '0a:7b:c8:a9:4e:dc', '0a:7b:c8:a9:4f:8a', '0a:7b:c8:a9:50:a6', '0a:7b:c8:a9:50:e2', '0a:7b:c8:a9:52:b5', '0a:7b:c8:a9:57:2c', '0a:7b:c8:a9:5c:b2', '0a:7b:c8:a9:5f:e7', '0a:7b:c8:a9:61:fd', '0a:7b:c8:a9:62:ba', '0a:7b:c8:a9:64:39', '0a:7b:c8:a9:64:c7', '0a:7b:c8:a9:6a:62', '0a:7b:c8:ab:04:1e', '0a:7b:c8:ab:1d:1b', '0a:7b:d8:a8:9d:d5', '0a:7b:d8:a9:4d:96', '0a:7b:d8:a9:4e:dc', '0a:7b:d8:a9:4f:8a', '0a:7b:d8:a9:50:a6', '0a:7b:d8:a9:50:e2', '0a:7b:d8:a9:52:b5', '0a:7b:d8:a9:57:2c', '0a:7b:d8:a9:5c:b2', '0a:7b:d8:a9:5f:e7', '0a:7b:d8:a9:61:fd', '0a:7b:d8:a9:62:ba', '0a:7b:d8:a9:64:39', '0a:7b:d8:a9:64:c7', '0a:7b:d8:a9:6a:62', '0a:7b:d8:ab:04:1e', '0a:7b:d8:ab:1d:1b', 'e2:55:a8:10:8f:51', 'e2:55:a8:10:8f:83', 'e2:55:a8:10:8f:9f', 'e2:55:a8:10:8f:b7', 'e2:55:a8:10:96:5d', 'e2:55:a8:10:96:88', 'e2:55:a8:10:a9:90', 'e2:55:a8:10:a9:b4', 'e2:55:a8:10:af:1e', 'e2:55:a8:10:af:1f', 'e2:55:a8:10:af:21', 'e2:55:a8:10:af:3a', 'e2:55:a8:10:af:46', 'e2:55:a8:10:af:4b', 'e2:55:a8:10:e5:48', 'e2:55:a8:10:e5:4a', 'e2:55:a8:10:e5:6a', 'e2:55:a8:10:e5:6b', 'e2:55:a8:11:17:d2', 'e2:55:a8:20:63:cf', 'e2:55:a8:20:64:34', 'e2:55:a8:20:64:7d', 'e2:55:a8:20:67:8c', 'e2:55:a8:20:67:c5', 'e2:55:a8:20:6a:46', 'e2:55:a8:20:6b:35', 'e2:55:a8:27:a5:59', 'e2:55:a8:57:cf:d7', 'e2:55:b8:10:8f:51', 'e2:55:b8:10:8f:83', 'e2:55:b8:10:8f:9f', 'e2:55:b8:10:8f:b7', 'e2:55:b8:10:96:5d', 'e2:55:b8:10:96:88', 'e2:55:b8:10:a9:90', 'e2:55:b8:10:a9:b4', 'e2:55:b8:10:af:1e', 'e2:55:b8:10:af:1f', 'e2:55:b8:10:af:21', 'e2:55:b8:10:af:3a', 'e2:55:b8:10:af:46', 'e2:55:b8:10:af:4b', 'e2:55:b8:10:e5:48', 'e2:55:b8:10:e5:4a', 'e2:55:b8:10:e5:6a', 'e2:55:b8:10:e5:6b', 'e2:55:b8:11:17:d2', 'e2:55:b8:20:63:cf', 'e2:55:b8:20:64:34', 'e2:55:b8:20:64:7d', 'e2:55:b8:20:67:8c', 'e2:55:b8:20:67:c5', 'e2:55:b8:20:6a:46', 'e2:55:b8:20:6b:35', 'e2:55:b8:27:a5:59', 'e2:55:b8:57:cf:d7'];

  // since the ouput of the model are numeric, the number index would
  // correspond to one of these named rooms or areas
  //list organised as the first column to link prediction number of the model to the room
  //columns after are rooms adjacent to the room in the first collumn as row.
  static const rooms = [["room1","room2"]]; //so for example, model predicts number 0 and that means room1, and adjacent to room1 is room2.

  //list of teachers for students to select that they are meeting in a room
  static const teachers = [];

  // Wifi network we are recording signal from
  static const network_name = "";

  void updatePredictNum(int predictNum){
    this.predictNum = predictNum;
    notifyListeners();
  }

  void updatePrediction(String location) {
    prediction = location;
    notifyListeners(); // Notify UI to update
  }

  void updateFinalLocation(String location) {
    finalLocation = location;
    notifyListeners(); // Notify UI to update
  }

  void updateTime(String time) {
    this.time = time;
    notifyListeners(); // Notify UI to update
  }

  void updateTeacher(String name) {
    teacher = name;
    notifyListeners(); // Notify UI to update
  }

  int getPredictNum(){
    return predictNum;
  }

  String getPrediction(){
    return prediction;
  }

  String getFinalLocation(){
    return finalLocation;
  }

  String getTime(){
    return time;
  }

  String getTeacher(){
    return teacher;
  }
}