import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceAdminPage extends StatefulWidget {
  const AttendanceAdminPage({super.key});

  @override
  _AttendanceAdminPageState createState() => _AttendanceAdminPageState();
}

class _AttendanceAdminPageState extends State<AttendanceAdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();

  Future<List<DocumentSnapshot>> _getUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs;
  }

  void _markAttendance(String userId, bool isPresent) {
    _firestore.collection('attendance').add({
      'userId': userId,
      'date': _selectedDate,
      'status': isPresent ? 'present' : 'absent',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance marked')),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Mark Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _pickDate(context),
              child: Text('Select Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
            ),
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _getUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  List<DocumentSnapshot> users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      String userId = users[index].id;
                      String userName = users[index]['name'];
                      return ListTile(
                        title: Text(userName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _markAttendance(userId, true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _markAttendance(userId, false),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
