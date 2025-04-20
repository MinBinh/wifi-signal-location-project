import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../WifiData.dart';

class NoWifi extends StatelessWidget {
  const NoWifi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 40.0),
              alignment: Alignment.center,
              child: Text(WifiData.network_name+" Network not detected"),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(150),
                  shape: CircleBorder(),
                  elevation: 10.0,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/scan");
                },
                child: Text("Rescan", style: TextStyle(fontSize: 20.0),)),
          ],
        )
      )
    );
  }
}