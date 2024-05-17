import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;
// import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:latest/notification.dart';

class Graph extends StatefulWidget {
  const Graph({super.key});

  @override
  State<Graph> createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  final List<double> _data = [];
  final List<Color> _colors = [];
  Timer? _timer;
  double? data;
  bool isAlarmTriggered = false;
  bool isAlarmTriggered1 = false;
  List<Map<String, dynamic>> dataList1 = [];

  @override
  void initState() {
    super.initState();
    _startTimer();
    // generateRandomNumbers();
    streamDataToFirestore();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final newValue = Random().nextDouble() * 100;
        _data.add(newValue); // Random data between 0 and 100
        data = newValue; // Extract the latest value
        if (_data.length > 10) {
          _data.removeAt(0); // Remove old data to keep the graph updated
        }
        final color = _getColor(newValue);
        _colors.add(color); // Record color of the latest data point
        if (!isAlarmTriggered &&
            (color == Colors.red || color == Colors.amber)) {
          setState(() {
            isAlarmTriggered = true;
            triggerAlarm();
          });
        }
      });
    });
  }

  void triggerAlarm() {
    setState(() {
      Notifierhelper.pushNotification(
          title: "Critical Alert", body: "The Graph has turned orange/red");
      // print(isAlarmTriggered);
      isAlarmTriggered = false;
    });
  }

  Color _getColor(double value) {
    if (value < 40) {
      return Colors.green;
    } else if (value >= 40 && value < 55) {
      return Colors.lightGreen;
    } else if (value >= 55 && value < 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Future<void> streamDataToFirestore() async {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await FirebaseFirestore.instance.collection("collection").add({
        'data': _data.last,
        'timestamp': DateTime.now().toIso8601String(),
      });
      print("object");
    });
  }

  Future<void> getDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("collection").get();

      List<Map<String, dynamic>> dataList = [];
      for (var doc in querySnapshot.docs) {
        // Convert each document to a map
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        dataList.add(data);
      }
      setState(() {
        dataList1 = dataList;
      });
      print(dataList1);
    } catch (e) {
      print("Error retrieving data from Firestore: $e");
      AnimatedSnackBar.material(
        "Error retrieving data from Firestore",
        type: AnimatedSnackBarType.error,
        duration: const Duration(seconds: 1),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
        ),
        mobileSnackBarPosition: MobileSnackBarPosition.top,
      ).show(context);
    }
  }

  Future<void> createExcelSheet(List<Map<String, dynamic>> dataList) async {
    final Workbook workbook = Workbook();

    // Add a worksheet to the workbook
    final Worksheet sheet = workbook.worksheets[0];

    // Set header row
    for (int row = 0; row < dataList.length; row++) {
      sheet.getRangeByName("A${row + 1}").setText("${dataList[row]['data']}");
    }
    for (int row = 0; row < dataList.length; row++) {
      sheet
          .getRangeByName("B${row + 1}")
          .setText("${dataList[row]['timestamp']}");
    }
    // Save the workbook
    final List<int> bytes = workbook.saveAsStream();

    // Get the device's documents directory
    final String path = (await getApplicationSupportDirectory()).path;
    final String filePath = '$path/example.xlsx';

    // Write the Excel file to disk
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    // Dispose the workbook
    workbook.dispose();
    OpenFile.open(filePath);

    print('Excel file created and saved at: $filePath');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: Image.asset("assets/images/outr.png")),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Image.asset("assets/images/spectrum.png")),
          )
        ],
      ),
      body: Column(
        children: [
          Text(
            "The value is : ${data?.toStringAsFixed(2)}",
            style: const TextStyle(fontFamily: "Oswaldb"),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  lineBarsData: _data.map((value) {
                    return value < 40
                        ? LineChartBarData(
                            spots: _data
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: false),
                            dotData: const FlDotData(show: false),
                            color: Colors.green,
                          )
                        : value >= 40 && value < 55
                            ? LineChartBarData(
                                spots: _data
                                    .asMap()
                                    .entries
                                    .map((e) =>
                                        FlSpot(e.key.toDouble(), e.value))
                                    .toList(),
                                isCurved: true,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(show: false),
                                dotData: const FlDotData(show: false),
                                color: Colors.lightGreen,
                              )
                            : value >= 55 && value < 70
                                ? LineChartBarData(
                                    spots: _data
                                        .asMap()
                                        .entries
                                        .map((e) =>
                                            FlSpot(e.key.toDouble(), e.value))
                                        .toList(),
                                    isCurved: true,
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    belowBarData: BarAreaData(show: false),
                                    dotData: const FlDotData(show: false),
                                    color: Colors.amber,
                                  )
                                : LineChartBarData(
                                    spots: _data
                                        .asMap()
                                        .entries
                                        .map((e) =>
                                            FlSpot(e.key.toDouble(), e.value))
                                        .toList(),
                                    isCurved: true,
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    belowBarData: BarAreaData(show: false),
                                    dotData: const FlDotData(show: false),
                                    color: Colors.red,
                                  );
                  }).toList(),
                  minX: 0,
                  maxX: 10,
                  minY: 0,
                  maxY: 100,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          InkWell(
            onTap: () async {
              await getDataFromFirestore();
              await createExcelSheet(dataList1);
            },
            child: Container(
              height: 50,
              width: 150,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.black),
              child: const Center(
                  child: Text(
                "Download Excel",
                style: TextStyle(color: Colors.white, fontFamily: "Oswaldb"),
              )),
            ),
          )
        ],
      ),
    );
  }
}
