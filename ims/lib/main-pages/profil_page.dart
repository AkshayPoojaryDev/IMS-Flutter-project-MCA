import 'package:flutter/material.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ims/main-pages/img_picker.dart'; // Ensure correct import path
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  DateTime _dob = DateTime.now();
  File? _image;
  File? _resume;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _onImagePicked(File image) {
    setState(() {
      _image = image;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  void _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userProfile.exists) {
        setState(() {
          _nameController.text = userProfile['name'] ?? '';
          _qualificationController.text = userProfile['qualification'] ?? '';
          _dob = (userProfile['dob'] as Timestamp).toDate();
          _addressController.text = userProfile['address'] ?? '';
          _skillsController.text = userProfile['skills'] ?? '';
          _experienceController.text = userProfile['experience'] ?? '';
          // Load profile picture and resume if needed
        });
      }
    }
  }

  Future<void> _uploadResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc']);
    if (result != null) {
      setState(() {
        _resume = File(result.files.single.path!);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Upload profile image if available
        String? imageUrl;
        if (_image != null) {
          TaskSnapshot snapshot = await FirebaseStorage.instance.ref('profile_images/${user.uid}').putFile(_image!);
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        // Upload resume if available
        String? resumeUrl;
        if (_resume != null) {
          TaskSnapshot snapshot = await FirebaseStorage.instance.ref('resumes/${user.uid}').putFile(_resume!);
          resumeUrl = await snapshot.ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'qualification': _qualificationController.text,
          'dob': _dob,
          'address': _addressController.text,
          'skills': _skillsController.text,
          'experience': _experienceController.text,
          'profileImageUrl': imageUrl,
          'resumeUrl': resumeUrl,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );

        setState(() {
          _isEditing = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required bool enabled,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[200],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveProfile : () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Center(
                child: ImagePickerWidget(
                  onImagePicked: _onImagePicked,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _nameController,
                labelText: 'Name',
                enabled: _isEditing,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _qualificationController,
                labelText: 'Qualification',
                enabled: _isEditing,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text("Date of Birth: ${_dob.toLocal()}".split(' ')[0]),
                trailing: _isEditing
                    ? IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _addressController,
                labelText: 'Address',
                enabled: _isEditing,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _skillsController,
                labelText: 'Skills',
                enabled: _isEditing,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _experienceController,
                labelText: 'Experience',
                enabled: _isEditing,
              ),
              const SizedBox(height: 20),
              if (_isEditing)
                ElevatedButton(
                  onPressed: _uploadResume,
                  child: const Text('Upload Resume'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
