import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'internship_detail_page.dart'; // Import the InternshipDetailPage

class AvilInternshipPage extends StatelessWidget {
  const AvilInternshipPage({Key? key});

  Future<List<QueryDocumentSnapshot>> _fetchAppliedInternships() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not authenticated');
      return [];
    }
    print('User UID: ${user.uid}');

    final appliedInternshipsSnapshot = await FirebaseFirestore.instance
        .collection('internship_applications')
        .where('userId', isEqualTo: user.uid)
        .get();

    print('Fetched ${appliedInternshipsSnapshot.docs.length} documents');
    return appliedInternshipsSnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Internships'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _fetchAppliedInternships(),
        builder: (context, appliedSnapshot) {
          if (appliedSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (appliedSnapshot.hasError) {
            print('Error fetching data: ${appliedSnapshot.error}');
            return Center(child: Text('Error fetching data: ${appliedSnapshot.error}'));
          }

          final appliedInternships = appliedSnapshot.data ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('internships').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print('Error fetching data: ${snapshot.error}');
                return Center(child: Text('Error fetching data: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No internships available.'));
              }

              final internships = snapshot.data!.docs;

              final appliedInternshipTitles = appliedInternships.map((doc) => doc['internshipTitle']).toSet();
              final appliedInternshipList = internships.where((internship) {
                final title = internship['title'];
                return appliedInternshipTitles.contains(title);
              }).toList();

              final availableInternshipList = internships.where((internship) {
                final title = internship['title'];
                return !appliedInternshipTitles.contains(title);
              }).toList();

              final acceptedInternshipList = appliedInternshipList.where((internship) {
                final status = internship['status'];
                return status == 'accepted';
              }).toList();

              return ListView(
                children: [
                  if (acceptedInternshipList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Accepted Internships',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...acceptedInternshipList.map((internship) => InternshipCard(internship: internship)).toList(),
                  ],
                  if (appliedInternshipList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Applied Internships',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...appliedInternshipList.map((internship) => InternshipCard(internship: internship)).toList(),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Available Internships',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...availableInternshipList.map((internship) => InternshipCard(internship: internship)).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class InternshipCard extends StatelessWidget {
  final QueryDocumentSnapshot internship;

  const InternshipCard({required this.internship});

  @override
  Widget build(BuildContext context) {
    final title = internship['title'];
    final description = internship['description'];
    final type = internship['type'];
    final location = internship['location'];
    final status = internship['status'] ?? 'available'; // Assuming 'status' field exists

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            SizedBox(height: 5),
            Row(
              children: [
                Chip(
                  label: Text(type),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(width: 10),
                Text('Location: $location'),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InternshipDetailPage(
                title: title,
                description: description,
                type: type,
                location: location,
                status: status,
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AvilInternshipPage(),
  ));
}
