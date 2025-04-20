import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:developer' as logDev;

import 'dart:convert';
import "app/WifiData.dart";

int placeCollectNumber = 0;
var all = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  Color huntButtonColor = Colors.lightBlue;
  String? connectedBSSID;

  @override
  void initState() {
    super.initState();
    _getConnectedBSSID();

  }
  
  Future<void> _getConnectedBSSID() async {
    final info = NetworkInfo();
    connectedBSSID = await info.getWifiBSSID(); // Fetch the SSID of the currently connected network
    setState(() {});
  }

  Future<void> huntWiFis() async {
    setState(() => huntButtonColor = Colors.red);
    // number used to see the number of scans made in the JSON file
    placeCollectNumber = 0;
    // Loops the collecting 60 times, change to 1 to do singular collection, or any number of times.
    while (placeCollectNumber < 40) {
      try {
        wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!;

        // Filter the results to only include networks named "Concordia Students"
        wiFiHunterResult.results = wiFiHunterResult.results
            .where((network) => network.ssid == WifiData.network_name)
            .toList();

        // Sort the filtered results by signal strength (level) in descending order
        wiFiHunterResult.results.sort((a, b) => b.level.compareTo(a.level));

        // Move the connected network to the top if it exists in the list
        if (connectedBSSID != null) {
          final connectedNetwork = wiFiHunterResult.results.where(
                  (network) => network.bssid == connectedBSSID).toList();
          String currentTime = DateTime.now().toIso8601String();

          List<Map<String, dynamic>> wifiData = wiFiHunterResult.results.map((
              wifi) {
            return {
              "bssid": wifi.bssid,
              "signal_strength": wifi.level,
            };
          }).toList();

          placeCollectNumber += 1;

          Map<String, dynamic> jsonData = {
            "room": "Outside 4014",
            //"place_collection_number": placeCollectNumber,
            "time": currentTime,
            "wifi": wifiData,
          };
          //Convert to JSON string
          final jsonString = jsonEncode(jsonData);

          all.add(jsonString);
          logDev.log(all.toString(), name: "wifilog");

          logDev.log(placeCollectNumber.toString(), name: "ScansNUM");
        }
      } on PlatformException catch (exception) {
        print(exception.toString());
      }

      if (!mounted) return;
      await Future.delayed(Duration(seconds: 1));
    }
    setState(() => huntButtonColor = Colors.lightBlue);
    logDev.log(all.toString(), name: "FINAL----wifilog");

  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WiFiHunter'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(huntButtonColor)),
                    onPressed: () => huntWiFis(),
                    child: const Text('Hunt Networks')
                ),
              ),

              wiFiHunterResult.results.isNotEmpty ? Container(
                margin: const EdgeInsets.only(bottom: 20.0, left: 30.0, right: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(wiFiHunterResult.results.length, (index) {
                    final network = wiFiHunterResult.results[index];
                    final isConnected = network.bssid == connectedBSSID;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      color: isConnected ? Colors.yellow : null, // Highlight connected network with yellow
                      child: ListTile(
                          leading: Text(network.level.toString() + ' dBm'),
                          title: Text(network.ssid),
                          subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Connected to : ' + connectedBSSID.toString()),
                                Text('BSSID : ' + network.bssid),
                                Text('Level : ' + network.level.toString() + ' dBm'),
                                Text('Capabilities : ' + network.capabilities),
                                Text('Frequency : ' + network.frequency.toString() + ' MHz'),
                                Text('Channel Width : ' + network.channelWidth.toString()),
                                Text('Timestamp : ' + network.timestamp.toString())
                              ]
                          )
                      ),
                    );
                  }),
                ),
              ) : Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                child: const Text(
                  'No networks found',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
