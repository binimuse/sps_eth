import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/call_class_controller.dart';

class CallClassView extends GetView<CallClassController> {
  const CallClassView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CallClassView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CallClassView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
