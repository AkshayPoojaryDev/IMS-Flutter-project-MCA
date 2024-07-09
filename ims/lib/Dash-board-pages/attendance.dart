import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final DateTime _firstDay = DateTime.utc(2023, 1, 1);
  final DateTime _lastDay = DateTime.utc(2024, 12, 31);  // Updated to include 2024
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final TextEditingController _leaveReasonController = TextEditingController();
  DateTime? _leaveStartDate;
  DateTime? _leaveEndDate;
  List<DateTime> _attendanceDays = [];

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _leaveReasonController.dispose();
    super.dispose();
  }

  void _loadAttendanceData() async {
    FirebaseFirestore.instance
        .collection('attendance')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _attendanceDays = snapshot.docs.map((doc) {
          Timestamp timestamp = doc['date'];
          return timestamp.toDate();
        }).toList();
      });
    });
  }

  void _applyForLeave() {
    if (_leaveStartDate == null || _leaveEndDate == null || _leaveReasonController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Leave Application Failed'),
            content: const Text('Please fill in all fields.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    FirebaseFirestore.instance.collection('leave_applications').add({
      'start_date': _leaveStartDate,
      'end_date': _leaveEndDate,
      'reason': _leaveReasonController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave Application Successful'),
          content: const Text('Your leave application has been submitted.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalDays = DateTime.now().difference(_firstDay).inDays + 1;
    int attendedDays = _attendanceDays.length;
    double attendancePercentage = attendedDays / totalDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TableCalendar(
                firstDay: _firstDay,
                lastDay: _lastDay,
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    for (DateTime d in _attendanceDays) {
                      if (isSameDay(day, d)) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Attendance Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CircularPercentIndicator(
                radius: 100.0,
                lineWidth: 10.0,
                percent: attendancePercentage,
                center: Text(
                  '${(attendancePercentage * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                progressColor: Colors.green,
              ),
              const SizedBox(height: 20),
              Text(
                'You have attended $attendedDays out of $totalDays days.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 20),
              const Text(
                'Apply for Leave',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _leaveReasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Leave',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _leaveStartDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _leaveStartDate == null
                              ? 'Start Date'
                              : 'Start: ${_leaveStartDate!.toLocal()}'.split(' ')[0],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _leaveEndDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _leaveEndDate == null
                              ? 'End Date'
                              : 'End: ${_leaveEndDate!.toLocal()}'.split(' ')[0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _applyForLeave,
                child: const Text('Apply for Leave'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
