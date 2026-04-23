import 'package:flutter/material.dart';

class UserUpdate extends StatefulWidget {
  const UserUpdate({super.key});

  @override
  State<UserUpdate> createState() => _UserUpdateState();
}

class _UserUpdateState extends State<UserUpdate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update User')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('User Update Content'),
      ),
    );
  }
}
