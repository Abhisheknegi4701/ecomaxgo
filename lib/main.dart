import 'dart:io';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Android Hardware Details Task'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showBattery = false;
  bool showConnection = false;
  bool showMac = false;
  bool showBluetoothDevices = false;
  int batteryLevel = 0;
  bool wifiState = false;
  String macAddress = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.height / 2,
              child: GridView(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                ),
                children: [
                  GestureDetector(
                    onTap: () async {
                      if(showBattery){
                        setState(() {
                          showBattery = false;
                        });
                      }else{
                        if(Platform.isAndroid){
                          await BatteryInfoPlugin().androidBatteryInfo.then((value){
                            if(value != null){
                              batteryLevel = value.batteryLevel ?? 0;
                            }
                            setState(() {
                              showBattery = true;
                            });
                          });
                        }else{
                          await BatteryInfoPlugin().iosBatteryInfo.then((value){
                            if(value != null){
                              batteryLevel = value.batteryLevel ?? 0;
                            }
                            setState(() {
                              showBattery = true;
                            });
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5.0,
                          ),],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Fetch Battery Percentage", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),),
                          Text(showBattery? "Percentage: $batteryLevel %" : "", textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if(showConnection){
                        setState(() {
                          showConnection = false;
                        });
                      }else{
                        final connectivityResult = await (Connectivity().checkConnectivity());
                        if (connectivityResult == ConnectivityResult.wifi) {
                          wifiState = true;
                        } else {
                          wifiState = false;
                        }
                        setState(() {
                          showConnection = true;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5.0,
                          ),],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Fetch Wi-Fi State", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),),
                          Text(showConnection? "Wi-Fi State: $wifiState" : "", textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      MethodChannel channel = const MethodChannel('get_mac');
                      if(showMac){
                        setState(() {
                          showMac = false;
                        });
                      }else{
                        macAddress = await channel.invokeMethod('getMacAddress');
                        setState(() {
                          showMac = true;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5.0,
                          ),],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Fetch and Show MAC Address", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),),
                          Text(showMac? "MAC Address: $macAddress" : "", textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),),
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: FlutterBluePlus.isScanning,
                    initialData: false,
                    builder: (c, snapshot) {
                      if (snapshot.data ?? false) {
                        return GestureDetector(
                          onTap: () async {
                            try {
                              FlutterBluePlus.stopScan();
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5.0,
                                ),],
                            ),
                            child: const Center(child: Text("Stop", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),)),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () async {
                            try {
                              await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15), androidUsesFineLocation: false);
                            } catch (e) {
                              print(e);
                            }
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5.0,
                                ),],
                            ),
                            child: const Center(child: Text("Fetch and List Bluetooth Protocols", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),)),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 2,
              color: Colors.green,
              child: StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.fromFuture(FlutterBluePlus.connectedSystemDevices),
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: (snapshot.data ?? [])
                      .map((d) => ListTile(
                    title: Text(d.localName, style: const TextStyle(color: Colors.black),),
                    subtitle: Text(d.remoteId.toString(), style: const TextStyle(color: Colors.black),),
                  ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

}


