import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:developer' as logDev;

import 'package:sklite/neighbors/neighbors.dart';

import 'dart:convert';
import "app/WifiData.dart";

int placeCollectNumber = 0;

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
List<double> jsontocsv(List<Map<String, dynamic>> wifiData) {
  List<int> signalStrengths = List.filled(WifiData.bssids.length, 0);

  // Create a map for BSSID signal strengths
  Map<String, int> bssidSignal = {
    for (var wifi in wifiData)
      wifi['bssid']: wifi['signal_strength']
  };

  // Update the signal strengths in the output list
  for (int i = 0; i < WifiData.bssids.length; i++) {
    if (bssidSignal.containsKey(WifiData.bssids[i])) {
      signalStrengths[i] = bssidSignal[WifiData.bssids[i]]!;
    }
  }
  return signalStrengths.map((e) => e.toDouble()).toList();
}

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
  late KNeighborsClassifier model;
  late var Prediction;

  @override
  void initState() {
    import_model();
    super.initState();
    _getConnectedBSSID();
  }

  /* this function imports the json file which has the training data (fitX & fitY)
  and other parameters (n_neighbours, p, and classsse) needed to intialises the KNN model.*/
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
  
  Future<void> _getConnectedBSSID() async {
    final info = NetworkInfo();
    connectedBSSID = await info.getWifiBSSID(); // Fetch the SSID of the currently connected network
    setState(() {});
  }

  Future<void> huntWiFis() async {
    setState(() => huntButtonColor = Colors.red);

    try {
      wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!;

      // Filter the results to only include networks named "Concordia Students"
      wiFiHunterResult.results = wiFiHunterResult.results
          .where((network) => network.ssid == WifiData.network_name)
          .toList();

      // Sort the filtered results by signal strength (level) in descending order
      wiFiHunterResult.results.sort((a, b) => b.level.compareTo(a.level));

      if (connectedBSSID != null) {
        final connectedNetwork = wiFiHunterResult.results.where(
                (network) => network.bssid == connectedBSSID).toList();

        // Json list of wifi signals collected
        List<Map<String, dynamic>> wifiData = wiFiHunterResult.results.map((wifi) {
           return {
             "bssid": wifi.bssid,
             "signal_strength": wifi.level,
           };
        }).toList();
        placeCollectNumber += 1;

        /* log message that shows the input of wifi signals
        that would be put into the model and the output that
        was given from the input */
        logDev.log("--------------------------------------------------------------", name: "---");
        // converts to a list of double variables
        List<double> signal_list = jsontocsv(wifiData)
            .map((e) => e as double)
            .toList();
        // extracted wifi signals
        logDev.log(signal_list.toString(), name: "wifiLog");
        // normalised wifi signals
        var norm = normalise(signal_list);
        // said normalised wifi signal output on the log
        logDev.log(norm.toString(), name:"normalised_wifi");
        //predicting location area model
        if (model != null) {
          Prediction = model.predict(norm);
          logDev.log(Prediction.toString(), name: "model");
        } else {logDev.log("model null", name: "model");}
        logDev.log("--------------------------------------------------------------", name: "---");
      }
    } on PlatformException catch (exception) {
      print(exception.toString());
    }
    if (!mounted) return;

    setState(() => huntButtonColor = Colors.lightBlue);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WiFiHunter Concordia'),
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
                alignment: Alignment.center,
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(huntButtonColor)),
                    onPressed: () => huntWiFis(),
                    child: const Text('Hunt Networks')
                ),
              ),

              // this block shows the location that was predicted from the model
              placeCollectNumber != 0 ? Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 20.0, left: 30.0, right: 30.0),
                child: Text('Location: ' + WifiData.rooms[Prediction][0].toString()),
              ) : Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 20.0, left: 30.0, right: 30.0),
                child: Text('No Location Predicted Yet'),
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
