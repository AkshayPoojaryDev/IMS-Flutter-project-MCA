import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InternshipDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String type;
  final String location;
  final String status;

  const InternshipDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.status,
  }) : super(key: key);

  @override
  _InternshipDetailPageState createState() => _InternshipDetailPageState();
}

class _InternshipDetailPageState extends State<InternshipDetailPage> {
  bool _hasApplied = false;
  String _applicationStatus = '';

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
  }

  Future<void> _checkIfApplied() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final application = await FirebaseFirestore.instance
        .collection('internship_applications')
        .where('userId', isEqualTo: user.uid)
        .where('internshipTitle', isEqualTo: widget.title)
        .get();

    if (application.docs.isNotEmpty) {
      setState(() {
        _hasApplied = true;
        _applicationStatus = application.docs.first['status'];
      });
    }
  }

  Future<void> _applyForInternship(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to apply.')),
      );
      return;
    }

    final userProfile = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!userProfile.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User profile not found.')),
      );
      return;
    }

    final applicationData = {
      'userId': user.uid,
      'userName': userProfile['name'],
      'userEmail': user.email,
      'internshipTitle': widget.title,
      'internshipDescription': widget.description,
      'internshipType': widget.type,
      'internshipLocation': widget.location,
      'status': 'applied',
      'appliedAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('internship_applications').add(applicationData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Application submitted successfully.')),
    );

    setState(() {
      _hasApplied = true;
      _applicationStatus = 'applied';
    });

    Navigator.pop(context);
  }

  Color _getStatusColor() {
    switch (_applicationStatus) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getButtonText() {
    switch (_applicationStatus) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return _hasApplied ? 'Applied' : 'Apply Now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: _getStatusColor(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(widget.type),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(width: 10),
                Text('Location: ${widget.location}'),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _hasApplied ? null : () => _applyForInternship(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasApplied ? Colors.grey : Colors.blue,
                minimumSize: Size(double.infinity, 60), // Full width and bigger button
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text(_getButtonText()),
            ),
          ],
        ),
      ),
    );
  }
}
