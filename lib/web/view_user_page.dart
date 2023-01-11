import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isd/Models/attendance_model.dart';
import 'package:isd/Models/user_model.dart';

import '../Utils/colors.dart';
import 'print_pdf_page.dart';

class ViewUserPage extends StatefulWidget {
  final String id;
  const ViewUserPage({Key? key, required this.id}) : super(key: key);

  @override
  State<ViewUserPage> createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {
  bool isLoading = false;
  UserModel? user;
  ScrollController scrollController = ScrollController();

  static final day = DateTime.now().day < 10
      ? "0${DateTime.now().day}"
      : DateTime.now().day.toString();

  static final month = DateTime.now().month < 10
      ? "0${DateTime.now().month}"
      : DateTime.now().month.toString();

  static final year = DateTime.now().year.toString();
  static final date = '$day$month$year';

  @override
  void initState() {
    super.initState();
    getUser();
    setState(() {
      selectedMonth = months[DateTime.now().month - 1];
      selectedYear = DateTime.now().year.toString();
    });
    Future.delayed(const Duration(seconds: 2), () {
      scrollController.animateTo(
        (DateTime.now().day - 1) * 45.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  getAttendanceData() async {
    List<AttendanceModel> attendanceList = [];
    final attendance = await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.id)
        .collection('Attendance')
        .get();
    final monthIndex = (months.indexOf(selectedMonth) + 1) < 10
        ? "0${months.indexOf(selectedMonth) + 1}"
        : (months.indexOf(selectedMonth) + 1).toString();
    final data = await FirebaseFirestore.instance
        .collection('Holidays')
        .doc('stpyAWihYEkKupbuJHgd')
        .get()
        .then(
          (value) => value.data()![DateFormat('MMM')
              .format(
                DateTime(
                  int.parse(selectedYear),
                  months.indexOf(selectedMonth) + 1,
                ),
              )
              .toLowerCase()],
        );

    List<String> holidays = [];
    holidays.clear();
    if (data != null) {
      for (var index = 0; index < data.length; index++) {
        final value = int.parse(data[index].toString()) < 10
            ? "0${data[index].toString()}"
            : data[index].toString();
        holidays.add(value);
      }
    }
    // final ldata = await FirebaseFirestore.instance
    //     .collection("Users")
    //     .doc(widget.id)
    //     .collection('Leaves')
    //     .get();
    // List<String> leaves = [];
    // leaves.clear();
    // final newLdata = ldata.docs
    //     .where(
    //       (element) => element.data()[DateFormat('MMM')
    //           .format(
    //             DateTime(
    //               int.parse(selectedYear),
    //               months.indexOf(selectedMonth) + 1,
    //             ),
    //           )
    //           .toLowerCase()],
    //     )
    //     .toList();
    // log(newLdata.toString());
    if (attendance.docs.any((element) =>
        element.id.substring(2, 4) == (monthIndex).toString() &&
        element.id.substring(4, 8) == selectedYear)) {
      final attendance = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.id)
          .collection('Attendance')
          .get();
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
          attendance.docs;

      for (var index = 0;
          index <
              daysInMonth(
                year: int.parse(selectedYear),
                month: (months.indexOf(selectedMonth) + 1),
              );
          index++) {
        final nowday =
            (index + 1) < 10 ? "0${index + 1}" : (index + 1).toString();
        final dataIndex = documents.indexWhere((element) =>
            (element.id[0] + element.id[1] == nowday.toString()) &&
            (element.id.substring(2, 4) == monthIndex) &&
            (element.id.substring(4, 8) == selectedYear));

        if (dataIndex != -1) {
          attendanceList.add(
            AttendanceModel(
              dateTime: nowday +
                  DateFormat('-MM-yyyy').format(
                    DateTime(
                      int.parse(selectedYear),
                      months.indexOf(selectedMonth) + 1,
                    ),
                  ),
              inTime: DateFormat('hh:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                  int.parse(documents[dataIndex].data()['indateTime']),
                ),
              ),
              outTime: documents[dataIndex].data()['outdateTime'] != ""
                  ? DateFormat('hh:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                        int.parse(documents[dataIndex].data()['outdateTime']),
                      ),
                    )
                  : "--:--",
              status: "Present",
            ),
          );
        } else {
          attendanceList.add(
            AttendanceModel(
              dateTime: nowday +
                  DateFormat('-MM-yyyy').format(
                    DateTime(
                      int.parse(selectedYear),
                      months.indexOf(selectedMonth) + 1,
                    ),
                  ),
              inTime: "--:--",
              outTime: "--:--",
              status: holidays.contains(nowday) ? "Holiday" : "Absent",
            ),
          );
        }
      }
    }

    GeneratePDF().generatePDF(
      widget.id,
      "$selectedMonth $selectedYear",
      attendanceList,
    );
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    final user = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.id)
        .get();
    this.user = UserModel.fromDocument(user);
    setState(() {
      isLoading = false;
    });
  }

  List<String> years = [
    "2022",
    "2023",
    "2024",
    "2025",
  ];

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  String selectedYear = "2022";
  String selectedMonth = "January";

  calculatePresent(List<QueryDocumentSnapshot<Map<String, dynamic>>> data) {
    int present = 0;
    for (var i = 0; i < data.length; i++) {
      if (data[i].id.substring(2, 4) == month.toString()) {
        present++;
      }
    }
    return present;
  }

  calculateAbsent(int present, List holidays) {
    List<String> days = [];
    for (var i = 0; i < daysInMonth(); i++) {
      days.add((i + 1).toString());
    }
    return days.length - present - holidays.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user!.photoUrl!),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Name: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                user!.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Email: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                user!.email,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'EID: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                user!.eid!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Month: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                DateFormat('MMMM yyyy').format(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('Holidays')
                              .doc("stpyAWihYEkKupbuJHgd")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData == false) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            int workingDays = 0;
                            String month = DateFormat('MMM')
                                .format(DateTime.now())
                                .toLowerCase();
                            List<dynamic> holidays = snapshot.data!.get(month);
                            final totaldays = daysInMonth();
                            workingDays = totaldays - holidays.length;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Working Days: ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "$workingDays Days",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                // Row(
                                //   children: [
                                //     const Text(
                                //       'Days Left: ',
                                //       style: TextStyle(
                                //         fontSize: 16,
                                //         fontWeight: FontWeight.bold,
                                //         color: Colors.white,
                                //       ),
                                //     ),
                                //     Text(
                                //      workingDays + " Days",
                                //       style: const TextStyle(
                                //         fontSize: 16,
                                //         color: Colors.white,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                const SizedBox(
                                  height: 5,
                                ),
                                StreamBuilder<
                                    QuerySnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(user!.id)
                                      .collection('Attendance')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData == false) {
                                      return const SizedBox();
                                    }
                                    return Row(
                                      children: [
                                        const Text(
                                          'Present Days: ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          "${calculatePresent(snapshot.data!.docs)} Days",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                StreamBuilder<
                                    QuerySnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(user!.id)
                                      .collection('Attendance')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text(
                                        "Loading...",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    }
                                    int absent = 0;
                                    absent = calculateAbsent(
                                      calculatePresent(snapshot.data!.docs),
                                      holidays,
                                    );
                                    return Row(
                                      children: [
                                        const Text(
                                          'Absent Days: ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          "$absent Days",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            );
                          }),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              items: years.map((String year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(
                                    year,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              value: selectedYear,
                              onChanged: (value) {
                                setState(() {
                                  selectedYear = value.toString();
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              items: months.map((String month) {
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(
                                    month,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              value: selectedMonth,
                              onChanged: (value) {
                                setState(() {
                                  selectedMonth = value.toString();
                                });
                                // getAttendanceData();
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            height: 58,
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                getAttendanceData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Go"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          leading: const Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 120,
                                child: Center(
                                  child: Text(
                                    'Day',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 50,
                              ),
                              SizedBox(
                                width: 120,
                                child: Center(
                                  child: Text(
                                    'In Time',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 50,
                              ),
                              SizedBox(
                                width: 120,
                                child: Center(
                                  child: Text(
                                    'Out Time',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 50,
                              ),
                              SizedBox(
                                width: 120,
                                child: Center(
                                  child: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            clipBehavior: Clip.antiAlias,
                            child: StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection("Users")
                                  .doc(user!.id)
                                  .collection("Attendance")
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final List<
                                        QueryDocumentSnapshot<
                                            Map<String, dynamic>>> documents =
                                    snapshot.data!.docs
                                        .where((element) =>
                                            element.id[2] + element.id[3] ==
                                            month.toString())
                                        .toList();
                                return ListView.builder(
                                  controller: scrollController,
                                  itemCount: daysInMonth(),
                                  itemBuilder: (context, index) {
                                    final nowday = (index + 1) < 10
                                        ? "0${index + 1}"
                                        : (index + 1).toString();
                                    final dataIndex = documents.indexWhere(
                                      (element) =>
                                          element.id[0] + element.id[1] ==
                                          nowday.toString(),
                                    );

                                    final day = DateFormat('EEEE').format(
                                        DateTime.parse(
                                            "${DateTime.now().year}-${DateTime.now().month < 10 ? "0${DateTime.now().month}" : DateTime.now().month}-$nowday"));
                                    return ListTile(
                                      tileColor: DateTime.now().day == index + 1
                                          ? Colors.blue.withOpacity(0.2)
                                          : Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      leading: Text(
                                        nowday +
                                            DateFormat('-MM-yyyy')
                                                .format(DateTime.now()),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: Center(
                                              child: Text(
                                                day,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 50,
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Center(
                                              child: Text(
                                                dataIndex != -1
                                                    ? DateFormat('hh:mm a')
                                                        .format(
                                                        DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                          int.parse(
                                                            snapshot.data!
                                                                    .docs[dataIndex]
                                                                    .data()[
                                                                'indateTime'],
                                                          ),
                                                        ),
                                                      )
                                                    : '--:--',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 50,
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Center(
                                              child: Text(
                                                dataIndex != -1 &&
                                                        snapshot.data!
                                                                    .docs[dataIndex]
                                                                    .data()[
                                                                'outdateTime'] !=
                                                            ""
                                                    ? DateFormat('hh:mm a')
                                                        .format(
                                                        DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                          int.parse(
                                                            snapshot.data!
                                                                    .docs[dataIndex]
                                                                    .data()[
                                                                'outdateTime'],
                                                          ),
                                                        ),
                                                      )
                                                    : '--:--',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 50,
                                          ),
                                          StreamBuilder<
                                                  DocumentSnapshot<
                                                      Map<String, dynamic>>>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("Holidays")
                                                  .doc("stpyAWihYEkKupbuJHgd")
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return const Center(
                                                    child: SizedBox(),
                                                  );
                                                }
                                                final List<dynamic> holidays =
                                                    snapshot.data!.get(
                                                        DateFormat('MMM')
                                                            .format(
                                                                DateTime.now())
                                                            .toLowerCase());
                                                return SizedBox(
                                                  width: 120,
                                                  child: Center(
                                                    child: Text(
                                                      day == 'Sunday' ||
                                                              holidays.contains(
                                                                  nowday)
                                                          ? 'Holiday'
                                                          : dataIndex != -1
                                                              ? "Present"
                                                              : (DateTime.now()
                                                                          .day) >
                                                                      index + 1
                                                                  ? "Absent"
                                                                  : "--",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: day ==
                                                                    'Sunday' ||
                                                                holidays
                                                                    .contains(
                                                                        nowday)
                                                            ? primaryColor
                                                            : Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  daysInMonth({int month = 0, int year = 0}) {
    if (month == 0 && year == 0) {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      final daysInMonth = lastDayOfMonth.difference(firstDayOfMonth).inDays + 1;
      return daysInMonth;
    } else {
      final firstDayOfMonth = DateTime(year, month, 1);
      final lastDayOfMonth = DateTime(year, month + 1, 0);
      final daysInMonth = lastDayOfMonth.difference(firstDayOfMonth).inDays + 1;
      return daysInMonth;
    }
  }

  lastSaturday() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    int nbDays = 0;
    DateTime currentDay = firstDayOfMonth;
    while (currentDay.isBefore(lastDayOfMonth)) {
      currentDay = currentDay.add(const Duration(days: 1));
      if (currentDay.weekday == DateTime.saturday) {
        nbDays += 1;
      }
    }
    return nbDays;
  }

  workingDays() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.difference(firstDayOfMonth).inDays + 1;
    final firstDayWeekday = firstDayOfMonth.weekday;
    final lastDayWeekday = lastDayOfMonth.weekday;
    final daysInFirstWeek = 8 - firstDayWeekday;
    final daysInLastWeek = lastDayWeekday;
    final daysInFullWeeks = daysInMonth - daysInFirstWeek - daysInLastWeek;
    final fullWeeks = daysInFullWeeks ~/ 7;
    final days = daysInFirstWeek + daysInLastWeek + (fullWeeks * 5);
    return days.toString();
  }
}
