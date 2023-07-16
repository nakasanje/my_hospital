import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:hospital_management_system/constants/colors.dart';

class LabReports extends StatefulWidget {
  final String userId;

  LabReports({required this.userId});

  @override
  _LabReportsState createState() => _LabReportsState();
}

class _LabReportsState extends State<LabReports> {
  bool _loading = false;
  late List _completedLabTests;
  late double width;
  late double height;

  // for real device
  final String pdfBaseUrl = 'http://0.0.0.0:8001/lab-reports';

  get key => null;

  // for emulator
  // final String pdfBaseUrl = 'http://10.0.2.2:8001/lab-reports';

  @override
  void initState() {
    _getLabTests();
    super.initState();
  }

// get the completed lab test list
  Future<void> _getLabTests() async {
    setState(() {
      _loading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('labTests')
          .where('user_id', isEqualTo: widget.userId)
          .where('list_type', isEqualTo: 'completed_lab_tests')
          .get();

      setState(() {
        _loading = false;
        _completedLabTests =
            querySnapshot.docs.map((doc) => doc.data()).toList();
      });

      print(_completedLabTests);
    } catch (error) {
      setState(() {
        _loading = false;
      });
      print('Failed to get completed lab tests: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Lab Reports'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: height,
              child: _completedLabTests.length > 0
                  ? SingleChildScrollView(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _getLabTests();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          height: height * 0.85,
                          width: double.infinity,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: _completedLabTests.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 6),
                                  margin:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  width: width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: colorWhite,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0, 3)),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                                text: 'Lab Test ID: ',
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children: [
                                                  TextSpan(
                                                    text: _completedLabTests[
                                                            index]['test_id']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ]),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: _completedLabTests[index]
                                                            ['test_status'] ==
                                                        'ACCEPTED'
                                                    ? Colors.green
                                                    : _completedLabTests[index][
                                                                'test_status'] ==
                                                            'PAID'
                                                        ? Colors.blue[700]
                                                        : _completedLabTests[
                                                                        index][
                                                                    'test_status'] ==
                                                                'COMPLETED'
                                                            ? Colors.grey[600]
                                                            : Colors.redAccent[
                                                                100]),
                                            child: Text(
                                              _completedLabTests[index]
                                                  ['test_status'],
                                              style: TextStyle(
                                                  color: colorWhite,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            width: width - 80,
                                            height: 50,
                                            child: Text(
                                              _completedLabTests[index]
                                                  ['details'],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Appointment: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          _completedLabTests[index]['date'] ==
                                                  null
                                              ? Text(
                                                  'N/A',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400),
                                                )
                                              : Text(
                                                  _completedLabTests[index]
                                                      ['date'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Lab Report',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PdfViewPage(
                                                      location:
                                                          '$pdfBaseUrl/${_completedLabTests[index]['file_location']}',
                                                      key: key,
                                                    ),
                                                  ));
                                            },
                                            child: Icon(
                                              Icons.remove_red_eye,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ),
                    )
                  : Center(
                      child: Text('No completed lab reports found!'),
                    ),
            ),
    );
  }
}

class PdfViewPage extends StatefulWidget {
  final String location;

  const PdfViewPage({required Key key, required this.location})
      : super(key: key);
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Lab Report'),
        ),
        body: const PDF(
                autoSpacing: true,
                enableSwipe: true,
                pageSnap: true,
                swipeHorizontal: true)
            .fromUrl(
          widget.location,
          // 'https://www.researchgate.net/profile/Mustafa_Saad7/publication/321318899_Automatic_Street_Light_Control_System_Using_Microcontroller/links/5c0e6a374585157ac1b74569/Automatic-Street-Light-Control-System-Using-Microcontroller.pdf',
          placeholder: (double progress) => Center(
            child: CircularProgressIndicator(
              value: progress,
            ),
          ),
          errorWidget: (dynamic error) => Center(child: Text(error.toString())),
        ));
  }
}
