import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hospital_management_system/constants/colors.dart';
import 'package:hospital_management_system/widgets/MyTextField.dart';

class Appointments extends StatefulWidget {
  final String userId;

  Appointments({required this.userId});

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  bool _loading = false;
  late List _appointments;
  late List _doctors;
  late double width;
  late double height;
  var _selectedDocotor;
  String dropdownValue = 'Update';

  TextEditingController _descriptionController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    _getAppointments();
    _getDoctors();
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

// get the appointments list
  Future<void> _getAppointments() async {
    setState(() {
      _loading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('user_id', isEqualTo: widget.userId)
          .where('list_type', isEqualTo: 'appointments')
          .get();

      setState(() {
        _loading = false;
        _appointments = querySnapshot.docs.map((doc) => doc.data()).toList();
      });

      print(_appointments);
    } catch (error) {
      setState(() {
        _loading = false;
      });
      print('Failed to get appointments: $error');
    }
  }

  Future<void> _getDoctors() async {
    setState(() {
      _loading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('user_id', isEqualTo: widget.userId)
          .where('list_type', isEqualTo: 'doctors')
          .get();

      setState(() {
        _loading = false;
        _doctors = querySnapshot.docs.map((doc) => doc.data()).toList();
      });

      print(_doctors);
    } catch (error) {
      setState(() {
        _loading = false;
      });
      print('Failed to get doctors: $error');
    }
  }

  Future<void> _addAppointment() async {
    setState(() {
      _loading = true;
    });

    try {
      final newAppointment = {
        'user_id': widget.userId.toString(),
        'doctor_id': _selectedDocotor['user_id'].toString(),
        'description': _descriptionController.text,
      };

      await FirebaseFirestore.instance
          .collection('appointments')
          .add(newAppointment);

      setState(() {
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _loading = false;
      });
      print('Failed to add appointment: $error');
    }
  }

  Future<void> _updateAppointment(String appointmentId) async {
    setState(() {
      _loading = true;
    });

    try {
      final updatedAppointment = {
        'description': _descriptionController.text,
      };

      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update(updatedAppointment);

      setState(() {
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _loading = false;
      });
      print('Failed to update appointment: $error');
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    setState(() {
      _loading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .delete();

      setState(() {
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _loading = false;
      });
      print('Failed to cancel appointment: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Appointments'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('New Appointment'),
        onPressed: () {
          _addNewAppointmentDialog(context);
        },
        icon: Icon(Icons.calendar_today),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: height,
              child: _appointments.length > 0
                  ? SingleChildScrollView(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _getAppointments();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          height: height * 0.35,
                          width: double.infinity,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: _appointments.length,
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
                                          Text(
                                            _appointments[index]['full_name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: _appointments[index][
                                                            'appointment_status'] ==
                                                        'PENDING'
                                                    ? Colors.orange
                                                    : _appointments[index][
                                                                'appointment_status'] ==
                                                            'ACCEPTED'
                                                        ? Colors.green
                                                        : Colors.blue[700]),
                                            child: Text(
                                              _appointments[index]
                                                  ['appointment_status'],
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
                                              _appointments[index]
                                                  ['description'],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Appointment: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          (_appointments[index]['date'] ==
                                                      null ||
                                                  _appointments[index]
                                                          ['time'] ==
                                                      null)
                                              ? Text(
                                                  'N/A',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )
                                              : Text(
                                                  '${_appointments[index]['date']}  ${_appointments[index]['time']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: DropdownButton<String>(
                                              isDense: true,
                                              isExpanded: true,
                                              icon: Icon(
                                                Icons.more_horiz,
                                              ),
                                              underline: Container(
                                                height: 0,
                                                color: Colors.deepPurpleAccent,
                                              ),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  dropdownValue = newValue!;
                                                });
                                              },
                                              items: <String>[
                                                'View',
                                                'Update',
                                                'Cancel'
                                              ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                    onTap: () {
                                                      print(value);
                                                      print(
                                                          _appointments[index]);

                                                      if (value == 'View') {
                                                        _viewAppointmentDialog(
                                                            context,
                                                            _appointments[
                                                                index]);
                                                      } else if (value ==
                                                              'Cancel' ||
                                                          value == 'Update') {
                                                        if (_appointments[index]
                                                                    [
                                                                    'appointment_status'] ==
                                                                'CANCELLED' ||
                                                            _appointments[index]
                                                                    [
                                                                    'appointment_status'] ==
                                                                'REJECTED' ||
                                                            _appointments[index]
                                                                    [
                                                                    'appointment_status'] ==
                                                                'COMPLETED') {
                                                          Fluttertoast
                                                              .showToast(
                                                            msg:
                                                                'This appointment has already been ${_appointments[index]['appointment_status']}!',
                                                            backgroundColor:
                                                                Colors.red[600],
                                                            textColor:
                                                                colorWhite,
                                                            toastLength: Toast
                                                                .LENGTH_LONG,
                                                          );
                                                        } else {
                                                          if (value ==
                                                              'Cancel') {
                                                            _cancelAppointment(
                                                                    _appointments[
                                                                            index]
                                                                        [
                                                                        'appointment_id'])
                                                                .then((_) {
                                                              Fluttertoast
                                                                  .showToast(
                                                                msg:
                                                                    'Appointment cancelled',
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                              );
                                                              _getAppointments();
                                                            }).catchError(
                                                                    (error) {
                                                              Fluttertoast
                                                                  .showToast(
                                                                msg:
                                                                    'Failed to cancel appointment: $error',
                                                                backgroundColor:
                                                                    Colors.red[
                                                                        600],
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                              );
                                                            });
                                                          } else if (value ==
                                                              'Update') {
                                                            _updateAppointmentDialog(
                                                                context,
                                                                _appointments[
                                                                        index][
                                                                    'appointment_id']);
                                                          }
                                                        }
                                                      }
                                                    },
                                                  );
                                                },
                                              ).toList(),
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
                      child: Text('No appointment data found!'),
                    ),
            ),
    );
  }

// adding new appointment dialog
  Future _addNewAppointmentDialog(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('New Appointment',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: colorWhite),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            child: DropdownButtonFormField(
                              value: _selectedDocotor,
                              items: _doctors
                                  .map((value) => DropdownMenuItem(
                                        child: Text(value["full_name"]),
                                        value: value,
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                print('inside on change');
                                setState(() {
                                  _selectedDocotor = value;
                                  print('set change: $value');
                                });
                              },
                              isExpanded: true,
                              iconEnabledColor: primaryColor,
                              dropdownColor: fillColor,
                              isDense: true,
                              iconSize: 30.0,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: primaryColor,
                                ),
                                filled: true,
                                fillColor: fillColor,
                                labelText: _selectedDocotor == null
                                    ? 'Select the Doctor'
                                    : 'Doctor',
                                contentPadding:
                                    EdgeInsets.fromLTRB(16, 10, 0, 10),
                                hintStyle: TextStyle(color: hintColor),
                                hintText: "Select the Doctor",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: primaryColor, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: primaryColor, width: 1.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: errorColor, width: 1),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: errorColor, width: 1),
                                ),
                                errorStyle: TextStyle(),
                              ),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          MyTextField(
                            hint: 'Description',
                            icon: Icons.note,
                            isMultiline: true,
                            maxLines: 5,
                            controller: _descriptionController,
                            validation: (val) {
                              if (val.isEmpty) {
                                return 'A description is required';
                              }
                              return null;
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                _addAppointment().then((_) {
                                  Fluttertoast.showToast(
                                    msg: 'Appointment added successfully',
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    toastLength: Toast.LENGTH_LONG,
                                  ).then((value) {
                                    setState(() {
                                      _descriptionController.clear();
                                    });
                                    Navigator.pop(context);
                                    _getAppointments();
                                  }).catchError((error) {
                                    Fluttertoast.showToast(
                                      msg: 'Failed to add appointment: $error',
                                      backgroundColor: Colors.red[600],
                                      textColor: Colors.white,
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                  });
                                }).catchError((error) {
                                  Fluttertoast.showToast(
                                    msg: 'Failed to add appointment: $error',
                                    backgroundColor: Colors.red[600],
                                    textColor: Colors.white,
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                });
                              }
                              ;
                              Container(
                                alignment: Alignment.center,
                                height: 20.0,
                                width: double.infinity,
                                child: Text(
                                  'SAVE',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // update appointments dialog
  Future<Future> _updateAppointmentDialog(context, appointmentId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('Update Appointment Details',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: colorWhite),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          MyTextField(
                            hint: 'Description',
                            icon: Icons.note,
                            isMultiline: true,
                            maxLines: 5,
                            controller: _descriptionController,
                            validation: (val) {
                              if (val.isEmpty) {
                                return 'The description is required';
                              }
                              return null;
                            },
                          ),
                          GestureDetector(onTap: () {
                            if (_formKey.currentState!.validate()) {
                              _updateAppointment(appointmentId).then((_) {
                                Fluttertoast.showToast(
                                  msg: 'Appointment updated successfully',
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  toastLength: Toast.LENGTH_LONG,
                                ).then((value) {
                                  setState(() {
                                    _descriptionController.clear();
                                  });
                                  Navigator.pop(context);
                                  _getAppointments();
                                }).catchError((error) {
                                  Fluttertoast.showToast(
                                    msg: 'Failed to update appointment: $error',
                                    backgroundColor: Colors.red[600],
                                    textColor: Colors.white,
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                });
                              }).catchError((error) {
                                Fluttertoast.showToast(
                                  msg: 'Failed to update appointment: $error',
                                  backgroundColor: Colors.red[600],
                                  textColor: Colors.white,
                                  toastLength: Toast.LENGTH_LONG,
                                );
                              });
                            }
                            ;
                            Container(
                              alignment: Alignment.center,
                              height: 30.0,
                              width: double.infinity,
                              child: Text(
                                'SAVE',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          );
        });
  }

  // view appointment details dialog
  Future<Future> _viewAppointmentDialog(context, appointment) async {
    await Future.delayed(Duration(milliseconds: 100));
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('Appointment Details',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: colorWhite),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        height: 60,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              Text(appointment['description']),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Date: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  Text(appointment['date'] != null
                                      ? appointment['date']
                                      : 'N/A')
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Time: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  Text(appointment['time'] != null
                                      ? appointment['time']
                                      : 'N/A')
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Comments: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              Text(appointment['comments'] != null
                                  ? appointment['comments']
                                  : 'N/A'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 20.0,
                      width: double.infinity,
                      child: Text(
                        'CLOSE',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
