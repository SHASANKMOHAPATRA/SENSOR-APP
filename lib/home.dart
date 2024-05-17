import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latest/add.dart';
import 'package:latest/graph.dart';
import 'package:latest/main.dart';
import 'package:latest/update.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  String? doc = "";
  Future<void> getDocIdByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(
              'your_collection') // Replace 'users' with your collection name
          .where('data4', isEqualTo: email) // Assuming email is unique
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          doc = querySnapshot.docs.first.id;
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

  Future<void> deleteDocument() async {
    try {
      await FirebaseFirestore.instance
          .collection("your_collection")
          .doc(doc)
          .delete();
      print('Document deleted successfully');
      AnimatedSnackBar.material(
        "Successfully deleted",
        type: AnimatedSnackBarType.success,
        duration: const Duration(seconds: 1),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
        ),
        mobileSnackBarPosition: MobileSnackBarPosition.top,
      ).show(context);
    } catch (error) {
      print('Error deleting document: ');
      AnimatedSnackBar.material(
        "Can't Delete data",
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

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => login()),
      );
      AnimatedSnackBar.material(
        "Logged Out",
        type: AnimatedSnackBarType.success,
        duration: const Duration(seconds: 1),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
        ),
        mobileSnackBarPosition: MobileSnackBarPosition.top,
      ).show(context);
    } catch (e) {
      AnimatedSnackBar.material(
        "Can't Sign Out",
        type: AnimatedSnackBarType.error,
        duration: const Duration(seconds: 1),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
        ),
        mobileSnackBarPosition: MobileSnackBarPosition.top,
      ).show(context);
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('your_collection')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error Occured'));
          }

          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Graph(),
                      ),
                    );
                  },
                  child: Card(
                      elevation: 3, // Sets the elevation of the card
                      margin: const EdgeInsets.all(
                          10), // Sets margin around the card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Sets border radius of the card
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BLOCK: ${doc['data1']}',
                                    style:
                                        const TextStyle(fontFamily: "Oswaldb"),
                                  ),
                                  Text(
                                    'LANDMARK: ${doc['data2']}',
                                    style:
                                        const TextStyle(fontFamily: "Oswaldb"),
                                  ),
                                  Text(
                                    'AREA: ${doc['data3']}',
                                    style:
                                        const TextStyle(fontFamily: "Oswaldb"),
                                  ),
                                  Text(
                                    'LATITUTE: ${doc['data4']}',
                                    style:
                                        const TextStyle(fontFamily: "Oswaldb"),
                                  ),
                                  Text(
                                    'LONGITUDE: ${doc['data5']}',
                                    style:
                                        const TextStyle(fontFamily: "Oswaldb"),
                                  ),
                                ],
                              ),
                              // Add more fields as needed
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      update(docdata: doc["data4"]),
                                ),
                              );
                              // Handle edit button tap
                            },
                          ),
                          InkWell(
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onTap: () {
                              getDocIdByEmail(doc["data4"]);
                              deleteDocument();
                            },
                            onLongPress: () async {
                              await _signOut();
                            },
                          )
                        ],
                      )),
                );
              },
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const add()),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
