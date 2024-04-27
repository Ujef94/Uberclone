import 'package:admin_uber_with_panel/methods/common_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DriversDataList extends StatefulWidget {
  const DriversDataList({super.key});

  @override
  State<DriversDataList> createState() => _DriversDataListState();
}

class _DriversDataListState extends State<DriversDataList> {
  final driversRecordsFromDatabase = FirebaseDatabase.instance.ref().child("drivers");
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: driversRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData)
      {
        if(snapshotData.hasError){
          return const Center(
            child: Text(
              "Error occurred. Try Later.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.pink,
              ),
            ),
          );
        }

        if(snapshotData.connectionState == ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List itemsList = [];
        dataMap.forEach((key, value) {
          itemsList.add({"key": key, ...value});
        });

        return ListView.builder(
          shrinkWrap: true,
          itemCount: itemsList.length,
          itemBuilder: ((context, index){
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                cMethods.data(
                  2,
                  SizedBox(height: 28,child: Text(itemsList[index]["id"].toString())),
                ),

                cMethods.data(
                  1,
                  Image.network(
                    itemsList[index]["photo"].toString(),
                    width: 28,
                    height: 28,
                  ),
                ),

                cMethods.data(
                  1,
                  SizedBox(height: 28,child: Text(itemsList[index]["name"].toString())),
                ),

                cMethods.data(
                  1,
                  SizedBox(
                    height: 28,
                    child: Text(itemsList[index]["car_details"]["vehicleModel"].toString() + " - "
                    + itemsList[index]["car_details"]["vehicleNumber"].toString()
                    ),
                  ),
                ),

                cMethods.data(
                  1,
                  SizedBox(height: 28,child: Text(itemsList[index]["phone"].toString())),
                ),

                cMethods.data(
                  1,
                  itemsList[index]["earnings"] != null ?
                  SizedBox(height: 28, child: Text(itemsList[index]["earnings"].toString()))
                      : SizedBox(height: 28, child: const Text(" 0")),
                ),

                cMethods.data(
                  1,
                  itemsList[index]["blockStatus"] == "no" ?
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(

                      onPressed: () async{
                        await FirebaseDatabase.instance.ref()
                            .child("drivers")
                            .child(itemsList[index]["id"])
                            .update(
                            {
                              "blockStatus": "yes",
                            });
                      },

                      child: const Text(
                        "Block",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.pink),
                      ),
                    ),
                  )
                      : ElevatedButton(
                    onPressed: () async{
                      await FirebaseDatabase.instance.ref()
                          .child("drivers")
                          .child(itemsList[index]["id"])
                          .update(
                          {
                            "blockStatus": "no",
                          });
                    },
                    child: const Text(
                      "Approve",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.pink),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
