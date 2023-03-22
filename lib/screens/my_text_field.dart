import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyTextField extends StatefulWidget {
  const MyTextField({Key? key}) : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  final List<String> _texts = [];
  int i = -1;

//pick image
  XFile? image;
  Future<void> _pickImage(ImageSource source) async {
    image = await _picker.pickImage(source: source);
    if (image != null) {
      print(image!.path);
    }
    //check if the image path ended with.jpeg  if yes change the image path to .jpg
    if (image!.path.endsWith('.jpeg')) {
      setState(() {
        image = XFile(image!.path.replaceAll('.jpeg', '.jpg'));
      });
    } else {
      setState(() {
        image = XFile(image!.path);
      });
    }
  }

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
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 100,
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
                _buildImage(),
                const Spacer(),
                _buildButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildBottomSheet(BuildContext context) {
    return Platform.isIOS
        ? showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    child: Row(
                      children: const [
                        Text('Take a picture'),
                        SizedBox(width: 8.0),
                        Icon(Icons.camera_alt_outlined),
                      ],
                    ),
                    onPressed: () {
                      _pickImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: Row(
                      children: const [
                        Text('Choose from gallery'),
                        SizedBox(width: 8.0),
                        Icon(Icons.image),
                      ],
                    ),
                    onPressed: () {
                      _pickImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
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
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined),
                      title: const Text('Take a picture'),
                      onTap: () {
                        _pickImage(ImageSource.camera);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.image),
                      title: const Text('Choose from gallery'),
                      onTap: () {
                        _pickImage(ImageSource.gallery);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.cancel),
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
  }

  _buildButton(BuildContext context) {
    return Platform.isIOS
        ? CupertinoButton(
            child: const Text('Pick Image'),
            onPressed: () {
              _buildBottomSheet(context);
            },
          )
        : ElevatedButton(
            onPressed: () {
              _buildBottomSheet(context);
            },
            child: const Text('Pick Image'),
          );
  }

  _buildIndicator() {
    return Platform.isIOS
        ? const Center(child: CupertinoActivityIndicator())
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildImage() {
    return FutureBuilder<XFile?>(
      future: image == null ? null : Future.value(image),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Container(
              height: 200.0,
              width: 200.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                image: DecorationImage(
                  image: FileImage(
                    File(
                      snapshot.data!.path,
                    ),
                  ),
                  fit: BoxFit.cover,
                ),
              ));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildIndicator();
        } else {
          return const SizedBox(
            height: 200.0,
            width: 200.0,
            child: Center(
                child: Icon(
              Icons.image_not_supported_rounded,
              size: 100.0,
            )),
          );
        }
      },
    );
  }
}
