import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isd/Utils/colors.dart';

import 'view_user_page.dart';

class AbsentEmployees extends StatefulWidget {
  const AbsentEmployees({Key? key}) : super(key: key);

  @override
  State<AbsentEmployees> createState() => _AbsentEmployeesState();
}

class _AbsentEmployeesState extends State<AbsentEmployees> {
  bool isLoading = false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> absentEmployees = [];

  @override
  void initState() {
    super.initState();
    getAbsentEmployees();
  }

  void getAbsentEmployees() async {
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

      if (userattendance.exists == false) {
        absentEmployees.add(element);
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
          "Absent Employees",
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
          child: absentEmployees.isEmpty
              ? const Center(
                  child: Text(
                    "No Absent Employees",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: absentEmployees.length,
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
                              NetworkImage(absentEmployees[index]["photoUrl"]),
                        ),
                        title: Text(
                          absentEmployees[index]["name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          absentEmployees[index]["email"],
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
                                  id: absentEmployees[index].id,
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
