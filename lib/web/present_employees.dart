import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isd/Utils/colors.dart';

import 'view_user_page.dart';

class PresentEmployees extends StatefulWidget {
  const PresentEmployees({Key? key}) : super(key: key);

  @override
  State<PresentEmployees> createState() => _PresentEmployeesState();
}

class _PresentEmployeesState extends State<PresentEmployees> {
  bool isLoading = false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> presentEmployees = [];

  @override
  void initState() {
    super.initState();
    getPresentEmployees();
  }

  void getPresentEmployees() async {
    setState(() {
      isLoading = true;
    });
    final data = await FirebaseFirestore.instance.collection("Users").get();
    for (var element in data.docs) {
      final userattendance = await FirebaseFirestore.instance
          .collection("Users")
          .doc(element.id)
          .collection("Attendance")
          .doc(DateFormat('ddMMyyyy').format(DateTime.now()))
          .get();

      if (userattendance.exists) {
        presentEmployees.add(element);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: [
        const Text(
          "Employees Present",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: presentEmployees.isEmpty
              ? const Center(
                  child: Text(
                    "No Employees Present",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: presentEmployees.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              NetworkImage(presentEmployees[index]["photoUrl"]),
                        ),
                        title: Text(
                          presentEmployees[index]["name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          presentEmployees[index]["email"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        trailing: SizedBox(
                          height: 40,
                          width: 100,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(
                                () => ViewUserPage(
                                  id: presentEmployees[index].id,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.visibility,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'View',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
