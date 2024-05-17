import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latest/home.dart';

class update extends StatefulWidget {
  final String docdata;
  const update({super.key, required this.docdata});

  @override
  State<update> createState() => _updateState();
}

class _updateState extends State<update> {
  TextEditingController block1 = TextEditingController();
  TextEditingController landmark1 = TextEditingController();
  TextEditingController area1 = TextEditingController();
  TextEditingController lat1 = TextEditingController();
  TextEditingController long1 = TextEditingController();
  String? doc1 = "";
  Future<void> getDocIdByEmail1(String email) async {
    print(email);
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(
              'your_collection') // Replace 'users' with your collection name
          .where('data4', isEqualTo: email) // Assuming email is unique
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print(querySnapshot.docs.first.id);
        setState(() {
          doc1 = querySnapshot.docs.first.id;
        });
      }
    } catch (error) {
      print('Error getting document ID');
      AnimatedSnackBar.material(
        "Can't Get ID",
        type: AnimatedSnackBarType.error,
        duration: const Duration(seconds: 1),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
        ),
        mobileSnackBarPosition: MobileSnackBarPosition.top,
      ).show(context);
      print("error");
    }
  }

  Future<void> _updateData() async {
    print(doc1);
    // Get a reference to the document
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('your_collection').doc(doc1);

    // Update the fields
    documentReference.update({
      'data1': block1.text,
      'data2': landmark1.text,
      'data3': area1.text,
      'data4': lat1.text,
      'data5': long1.text,
      // Add more fields as needed
    }).then((value) {
      print('Document updated successfully');
      AnimatedSnackBar.material(
        'Document updated successfully',
        type: AnimatedSnackBarType.success,
        duration: const Duration(seconds: 1),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
        ),
        mobileSnackBarPosition: MobileSnackBarPosition.top,
      ).show(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const home(),
        ),
      );

      // Navigate back to previous screen or perform any other action
    }).catchError((error) {
      print('Error updating document: $error');
      AnimatedSnackBar.material(
        'Error updating document',
        type: AnimatedSnackBarType.error,
        duration: const Duration(seconds: 1),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
        ),
        mobileSnackBarPosition: MobileSnackBarPosition.top,
      ).show(context);
    });
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
                controller: block1,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "ENTER BLOCK NAME",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: landmark1,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "ENTER LANDMARK",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: area1,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "ENTER AREA",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: lat1,
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
                controller: long1,
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
        onPressed: () async {
          if (block1.text.isEmpty ||
              landmark1.text.isEmpty ||
              area1.text.isEmpty ||
              lat1.text.isEmpty ||
              long1.text.isEmpty) {
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
            await getDocIdByEmail1(widget.docdata);
            await _updateData();
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
