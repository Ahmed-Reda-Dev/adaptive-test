import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  const MyTextField({Key? key}) : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _texts = [];
  int i = -1;

  void _addTextToList() {
    //check if the text exists in the list or not if exists give it a new id and add it to the list else just add it to the list
    if (_controller.text.isEmpty) {
      return;
    } else if (_texts.contains(_controller.text)) {
      setState(() {
        i++;
        _texts.add(_controller.text + i.toString());
        _controller.clear();
      });
    } else {
      setState(() {
        _texts.add(_controller.text);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter text',
                border: const OutlineInputBorder(),
                suffixIcon: GestureDetector(
                  onTap: _addTextToList,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 200.0,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 8.0,
                runSpacing: 8.0,
                children: _texts
                    .map(
                      (text) => Chip(
                        //display the text without i value
                        label: Text(text.contains(i.toString())
                            ? text.substring(
                                0, text.length - i.toString().length)
                            : text.substring(0, text.length)),
                        // Text(text.contains('1')
                        //     ? text.substring(0, text.length - 1)
                        //     : text),
                        onDeleted: () {
                          setState(() {
                            _texts.remove(text);
                            //print the index of the deleted text
                            print(_texts.indexOf(text));
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16.0),
            Platform.isIOS
                ? const Center(child: CupertinoActivityIndicator())
                : const Center(child: CircularProgressIndicator()),
            //button open bottom sheet with adaptive
            ElevatedButton(
              onPressed: () {
                Platform.isIOS
                    ? showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return CupertinoActionSheet(
                            title:
                                const Text('This is a cupertino action sheet'),
                            actions: [
                              CupertinoActionSheetAction(
                                child: const Text('Action 1'),
                                onPressed: () {},
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('Action 2'),
                                onPressed: () {},
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      )
                    : showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                            height: 250.0,
                            child: Column(
                              children: [
                                const ListTile(
                                  title:
                                      Text('This is a material bottom sheet'),
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text('Action 1'),
                                  onTap: () {},
                                ),
                                ListTile(
                                  title: const Text('Action 2'),
                                  onTap: () {},
                                ),
                                ListTile(
                                  title: const Text('Cancel'),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
              },
              child: const Text('Open Bottom Sheet'),
            ),
          ],
        ),
      ),
    );
  }
}
