import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latest/home.dart';

class add extends StatefulWidget {
  const add({super.key});

  @override
  State<add> createState() => _addState();
}

class _addState extends State<add> {
  TextEditingController block = TextEditingController();
  TextEditingController landmark = TextEditingController();
  TextEditingController area = TextEditingController();
  TextEditingController lat = TextEditingController();
  TextEditingController long = TextEditingController();
  void _addDataToFirestore() {
    String data1 = block.text;
    String data2 = landmark.text;
    String data3 = area.text;
    String data4 = lat.text;
    String data5 = long.text;
    // Retrieve data from other controllers as needed

    if (data1.isNotEmpty && data2.isNotEmpty) {
      FirebaseFirestore.instance.collection('your_collection').add({
        'data1': data1,
        'data2': data2,
        'data3': data3,
        'data4': data4,
        'data5': data5,
        // Add more fields as needed
      }).then((value) {
        print('Data added to Firestore');

        AnimatedSnackBar.material(
          'Data Added',
          type: AnimatedSnackBarType.success,
          duration: const Duration(seconds: 1),
          mobilePositionSettings: const MobilePositionSettings(
            topOnAppearance: 100,
          ),
          mobileSnackBarPosition: MobileSnackBarPosition.top,
        ).show(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const home()),
        );

        // Clear other controllers as needed
      }).catchError((error) {
        print('Error adding data to Firestore: $error');

        AnimatedSnackBar.material(
          'Error in Adding Data',
          type: AnimatedSnackBarType.error,
          duration: const Duration(seconds: 1),
          mobilePositionSettings: const MobilePositionSettings(
            topOnAppearance: 100,
          ),
          mobileSnackBarPosition: MobileSnackBarPosition.top,
        ).show(context);
      });
    }
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: block,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "ENTER BLOCK NAME",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: landmark,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "ENTER LANDMARK",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: area,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "ENTER AREA",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: lat,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "ENTER LATITUDE",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: long,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "ENTER LONGITUDE",
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (block.text.isEmpty ||
              landmark.text.isEmpty ||
              area.text.isEmpty ||
              lat.text.isEmpty ||
              long.text.isEmpty) {
            AnimatedSnackBar.material(
              'The above fields cannot be empty',
              type: AnimatedSnackBarType.error,
              duration: const Duration(seconds: 1),
              mobilePositionSettings: const MobilePositionSettings(
                topOnAppearance: 100,
              ),
              mobileSnackBarPosition: MobileSnackBarPosition.top,
            ).show(context);
            print("empty");
          } else {
            _addDataToFirestore();
          }
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
