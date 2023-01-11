// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:isd/Models/attendance_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

class GeneratePDF {
  void generatePDF(
      String user, String dateTime, List<AttendanceModel> data) async {
    final firestore = FirebaseFirestore.instance;
    final userDoc = await firestore.collection("Users").doc(user).get();
    final pdf = Document();
    pdf.addPage(
      MultiPage(
        pageTheme: const PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        ),
        footer: (Context context) {
          return Column(
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                child: Text(
                  "Page ${context.pageNumber} of ${context.pagesCount}",
                  style: Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
        build: (Context context) {
          return <Widget>[
            Header(
              level: 1,
              child: Column(
                children: [
                  Container(
                    color: const PdfColor(0.2, 0.95, 0.8),
                    height: 80,
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "ISD (Identity Scanner Device)",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Attendance Report",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "www.dousoftit.com",
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "DouSoft IT Solutions Pvt. Ltd.",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: const PdfColor(0.2, 0.95, 0.8),
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Name: ${userDoc["name"]}",
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "Email: ${userDoc["email"]}",
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "EID: ${userDoc["eid"]}",
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "Period: $dateTime",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Date: ${DateFormat.yMMMd().format(DateTime.now())}",
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "Time: ${DateFormat.jm().format(DateTime.now())}",
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Table.fromTextArray(
              context: context,
              cellAlignments: {
                0: Alignment.center,
                1: Alignment.centerRight,
                2: Alignment.centerRight,
                3: Alignment.centerRight,
              },
              headerAlignments: {
                0: Alignment.center,
                1: Alignment.centerRight,
                2: Alignment.centerRight,
                3: Alignment.centerRight,
              },
              headerHeight: 30,
              headerDecoration: const BoxDecoration(
                color: PdfColors.amber,
              ),
              border: null,
              headers: [
                "Date & Time",
                "InTime",
                "OutTime",
                "Status",
              ],
              cellPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              oddCellStyle: const TextStyle(
                color: PdfColors.black,
                fontSize: 10,
              ),
              oddRowDecoration: const BoxDecoration(
                color: PdfColors.amber50,
              ),
              data: <List<String>>[
                ...data.map(
                  (e) => [
                    e.dateTime,
                    e.inTime,
                    e.outTime,
                    e.status,
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      format: PdfPageFormat.a4,
    );
  }
}
