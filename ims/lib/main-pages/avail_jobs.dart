import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ims/main-pages/job_details.dart';


class AvailJobsPage extends StatelessWidget {
  const AvailJobsPage({super.key});

  void _navigateToDetail(BuildContext context, String title, String description, String type, String location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailPage(
          title: title,
          description: description,
          type: type,
          location: location,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Jobs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data.'));
                  }

                  final jobs = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      final title = job['title'];
                      final description = job['description'];
                      final type = job['type'];
                      final location = job['location'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(description),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(type),
                                    backgroundColor: Colors.green[100],
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Location: $location'),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            _navigateToDetail(
                              context,
                              title,
                              description,
                              type,
                              location,
                            );
                          },
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
