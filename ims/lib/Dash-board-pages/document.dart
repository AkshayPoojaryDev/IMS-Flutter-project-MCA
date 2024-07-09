import 'package:flutter/material.dart';

class DocumentPage extends StatelessWidget {
  const DocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document'),
      ),
      body: const Center(
        child: Text('Document Page Content'),
      ),
    );
  }
}
