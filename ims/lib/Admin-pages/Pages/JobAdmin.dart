import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobAdminPage extends StatefulWidget {
  const JobAdminPage({super.key});

  @override
  _JobAdminPageState createState() => _JobAdminPageState();
}

class _JobAdminPageState extends State<JobAdminPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  bool _isAdding = false;

  void _saveJob() {
    final jobData = {
      'title': titleController.text,
      'description': descriptionController.text,
      'type': typeController.text,
      'location': locationController.text,
      'createdAt': Timestamp.now(),
    };

    FirebaseFirestore.instance.collection('jobs').add(jobData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job added successfully')),
      );
      _clearForm();
    });
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    typeController.clear();
    locationController.clear();
    setState(() {
      _isAdding = false;
    });
  }

  void _deleteJob(String id) {
    FirebaseFirestore.instance.collection('jobs').doc(id).delete();
  }

  void _showEditDialog(DocumentSnapshot document) {
    titleController.text = document['title'] ?? '';
    descriptionController.text = document['description'] ?? '';
    typeController.text = document['type'] ?? '';
    locationController.text = document['location'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('jobs').doc(document.id).update({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'type': typeController.text,
                  'location': locationController.text,
                }).then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Job updated successfully')),
                  );
                  _clearForm();
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isAdding)
              Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveJob,
                    child: const Text('Save Job'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching jobs.'));
                  }

                  final jobs = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      final title = job['title'] ?? 'No title';
                      final description = job['description'] ?? 'No description';
                      final type = job['type'] ?? 'No type';
                      final location = job['location'] ?? 'No location';

                      return Card(
                        child: ListTile(
                          title: Text(title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(description),
                              Text('Type: $type'),
                              Text('Location: $location'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(job),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteJob(job.id),
                              ),
                            ],
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isAdding = !_isAdding;
            if (!_isAdding) {
              _clearForm();
            }
          });
        },
        child: Icon(_isAdding ? Icons.close : Icons.add),
      ),
    );
  }
}
