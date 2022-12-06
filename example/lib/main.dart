import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sms_mms/sms_mms.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController recipientController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController filePathController = TextEditingController();

  List<String> recipientsList = [];

  String? filePath;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SMS/MMS Example'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Flutter MMS helps in sending multimedia message using native message sender on ios/android',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (recipientsList.isNotEmpty)
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    itemCount: recipientsList.length,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8
                    ),
                    itemBuilder: (_, index) {
                      return recipientTile(recipientsList[index], index);
                    },
                    separatorBuilder: (_, index) {
                      return const SizedBox(
                        width: 16,
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: recipientController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter recipient numbers here',
                        label: const Text('Recipient'),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (recipientController.text.isEmpty) return;
                            recipientsList.add(recipientController.text);
                            recipientController.text = "";
                            setState(() {});
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: messageController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Enter your message here',
                        label: Text('Message'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: filePathController,
                      keyboardType: TextInputType.text,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'File path here',
                        label: const Text('Attached File'),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: pickFile,
                          icon: const Icon(Icons.file_present_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              MaterialButton(
                onPressed: sendMessage,
                color: Colors.blue,
                padding: const EdgeInsets.all(16),
                child: const Text('Open Message App' , style: TextStyle(
                  color: Colors.white
                ),),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget recipientTile(String number, int index) {
    return Chip(label: Text(number), deleteIcon: const Icon(Icons.close, size: 20,), onDeleted: () {
      recipientsList.removeAt(index);
      setState(() { });
    },);
  }

  Future<void> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      filePath = result.files.single.path!;
      if (filePath != null) {
        filePathController.text = filePath?.split("/").last ?? "";
      }
    }
  }

  Future<void> sendMessage() async {
    if (recipientsList.isNotEmpty) {
      await SmsMms.send(
          recipients: recipientsList,
          message: messageController.text,
          filePath: filePath);
    } else {
      Fluttertoast.showToast(msg: 'Please add at-least one recipient');
    }
  }
}
