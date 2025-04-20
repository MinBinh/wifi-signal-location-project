import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:developer' as logDev;

import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'dart:convert';
import 'package:sklite/neighbors/neighbors.dart';

import "../WifiData.dart";
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();

  String? connectedBSSID;
  late KNeighborsClassifier model;
  int placeCollectNumber = 0;
  int numRoutersFound = 0;

  // to give to WifiData.dart
  int? predictNum;
  String? prediction;
  String? time;

  late Future<void> scan;

  @override
  void initState() {
    super.initState();
    import_model();
    scan = huntWiFis();
  }

  void import_model() async{
    // json file with all the training data and model parameters
    String fileContent = await rootBundle.loadString('assets/wififlex.json');
    // seperating the Json into variables of list or values to be inputed into the model
    final jsonData = jsonDecode(fileContent);
    final List<List<double>> fitX = (jsonData["_fit_X"] as List)
        .map((e) => (e as List).map((item) => (item as num).toDouble()).toList())
        .toList();
    final List<int> fitY = jsonData["_y"].cast<int>();
    final List<int> classes = jsonData["classes"].cast<int>();
    final int n_neighbours = jsonData["n_neighbors"];
    final int p = jsonData["p"];
    // model is initialised
    model = KNeighborsClassifier(fitX,fitY,n_neighbours, p, classes);
  }

  /*  function that turns the wifi signals into a range of 0 - 1 (with -1 value for
BSSID wifi modems that were not detected) */
  List<double> normalise(List<double> row) {
    // Filter out non-zero signal values
    List<double> nonZeroSignals = row.where((x) => x != 0).toList();

    if (nonZeroSignals.isEmpty) {
      return row; // Return unchanged if all signals are zero
    }

    // Find the lowest and highest non-zero signal values
    double minNonZero = nonZeroSignals.reduce((a, b) => a < b ? a : b);
    double maxNonZero = nonZeroSignals.reduce((a, b) => a > b ? a : b);
    double range = maxNonZero - minNonZero;

    // Transform the signal values
    return row.map((x) {
      if (x == 0) {
        return -1.0; // Leave zeros unchanged
      } else if (x == minNonZero) {
        return 0.0; // Set the lowest value to 0.1
      } else {
        return (x - minNonZero) / range; // Scale other values
      }
    }).toList();
  }

  /*  Json values created when wifi is scan is then converted into a list of
just double values organised by a predetermined set of wifi BSSID names
for each list index to match the model inputs */
  List<double> jsontocsv(List<Map<String, dynamic>> wifi) {
    List<int> signalStrengths = List.filled(WifiData.bssids.length, 0);

    // Create a map for BSSID signal strengths
    Map<String, int> bssidSignal = {
      for (var data in wifi)
        data['bssid']: data['signal_strength']
    };

    // Update the signal strengths in the output list
    for (int i = 0; i < WifiData.bssids.length; i++) {
      if (bssidSignal.containsKey(WifiData.bssids[i])) {
        signalStrengths[i] = bssidSignal[WifiData.bssids[i]]!;
      }
    }
    return signalStrengths.map((e) => e.toDouble()).toList();
  }

  Future<void> _getConnectedBSSID() async {
    final info = NetworkInfo();
    connectedBSSID = await info.getWifiBSSID(); // Fetch the SSID of the currently connected network
  }

  Future<void> huntWiFis() async {

    await _getConnectedBSSID();

    try {
      wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!;
      // Filter the results to only include networks named "Concordia Students"
      wiFiHunterResult.results = wiFiHunterResult.results
          .where((network) => network.ssid == WifiData.network_name)
          .toList();
      if (connectedBSSID != null) {
        // Json list of wifi signals collected
        List<Map<String, dynamic>> wifi = wiFiHunterResult.results.map((wifi) {
          return {
            "bssid": wifi.bssid,
            "signal_strength": wifi.level,
          };
        }).toList();
        logDev.log(wifi.toString());

        placeCollectNumber += 1;
        //time
        time = DateTime.now().toIso8601String();

        numRoutersFound = wifi.length;
        if(numRoutersFound==0){return;}

        // converts to a list of double variables
        List<double> signal_list = jsontocsv(wifi)
            .map((e) => e as double)
            .toList();
        // normalised wifi signals
        // said normalised wifi signal output on the log
        // predicting location area model
        if (model != null) {
          predictNum = model.predict(normalise(signal_list));
          prediction = WifiData.rooms[predictNum!][0];
          logDev.log(predictNum.toString(), name: "model");
        } else {logDev.log("model null", name: "model");}
      }
    } on PlatformException catch (exception) {
      print(exception.toString());
    }
    setState(() {});
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {

    final globalData = Provider.of<WifiData>(context, listen: false);

    return FutureBuilder<void>(
      future: scan,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(
            appBar: AppBar(
              title: const Text('Flex Check-in'),
              leading: BackButton(
                // Back to App Main Screen of School App
              )
            ),
            body: Center(
              child : Column (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(), // Loading Spinner
                  SizedBox(height: 20),
                  Text(
                    "Scanning...", textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),
                  ),
                ],
              )
            )
          );
        }
        else{
          // Rescan Move to New Location
          if (numRoutersFound == 0){
            Future.microtask(() {
              Navigator.pushReplacementNamed(context, "/nowifi");
            });
            return SizedBox();
          }
          // go to WifiData global class
          if (predictNum != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              globalData.updatePredictNum(predictNum!);
              globalData.updatePrediction(prediction!);
              globalData.updateTime(time!);
            });
          }
          //go to HomeScreen
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, "/homescreen");
          });
          return SizedBox();
          // Empty widget to avoid UI flickering
        }
      },
    );
  }
}