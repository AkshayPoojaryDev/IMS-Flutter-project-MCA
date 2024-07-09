import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ApplicationsAdminPage extends StatefulWidget {
  const ApplicationsAdminPage({super.key});

  @override
  _ApplicationsAdminPageState createState() => _ApplicationsAdminPageState();
}

class _ApplicationsAdminPageState extends State<ApplicationsAdminPage> {
  final Stream<QuerySnapshot> _jobApplicationsStream =
      FirebaseFirestore.instance.collection('job_applications').snapshots();
  final Stream<QuerySnapshot> _internshipApplicationsStream =
      FirebaseFirestore.instance.collection('internship_applications').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications Admin'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle('Job Applications'),
            _buildApplicationsList(_jobApplicationsStream, 'job_applications', 'job'),
            _buildSectionTitle('Internship Applications'),
            _buildApplicationsList(_internshipApplicationsStream, 'internship_applications', 'internship'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildApplicationsList(Stream<QuerySnapshot> stream, String collection, String type) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Error fetching $collection: ${snapshot.error}');
          return Center(child: Text('Error fetching $collection applications.'));
        }

        final applications = snapshot.data?.docs ?? [];

        if (applications.isEmpty) {
          return Center(child: Text('No $collection applications found.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final application = applications[index].data() as Map<String, dynamic>?;

            if (application == null) {
              return const Center(child: Text('No data found.'));
            }

            // Extract fields based on the type of application
            final title = type == 'job' ? application['jobTitle'] ?? 'No title' : application['internshipTitle'] ?? 'No title';
            final description = type == 'job' ? application['jobDescription'] ?? 'No description' : application['internshipDescription'] ?? 'No description';
            final applicantName = application['userName'] ?? 'Unknown';
            final applicantEmail = application['userEmail'] ?? 'Unknown'; // Ensure userEmail is stored in Firestore
            final applicantId = application['userId'] ?? 'Unknown';
            final applicationDate = (application['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

            return Card(
              child: ListTile(
                title: Text(title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(description),
                    Text('Applicant: $applicantName'),
                    Text('Date: ${applicationDate.toLocal()}'.split(' ')[0]), // Displaying date part only
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _updateApplicationStatus(applications[index].id, collection, 'accepted', applicantEmail),
                          child: const Text('Accept', style: TextStyle(color: Colors.green)),
                        ),
                        TextButton(
                          onPressed: () => _updateApplicationStatus(applications[index].id, collection, 'rejected', applicantEmail),
                          child: const Text('Reject', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateApplicationStatus(String docId, String collection, String status, String applicantEmail) async {
    // Update the application status in Firestore
    await FirebaseFirestore.instance.collection(collection).doc(docId).update({'status': status});

    // Send email to the user
    await _sendEmailNotification(applicantEmail, status);
  }

  Future<void> _sendEmailNotification(String email, String status) async {
    final smtpServer = gmail('your-email@gmail.com', 'your-email-password'); // Use your email credentials or an API key
    final message = Message()
      ..from = const Address('your-email@gmail.com', 'Your App Name')
      ..recipients.add(email)
      ..subject = 'Application Status Update'
      ..text = status == 'accepted' 
          ? 'Congratulations! Your application has been accepted.'
          : 'We regret to inform you that your application has been rejected.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      print('Message not sent. \n$e');
    }
  }
}
