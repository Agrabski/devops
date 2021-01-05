import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ShowOrPickImage extends StatefulWidget {
  final Uint8List initialImageData;

  const ShowOrPickImage({Key key, @required this.initialImageData})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ShowOrPickImageState(initialImageData);
  }
}

class _ShowOrPickImageState extends State<ShowOrPickImage> {
  Uint8List imageData;
  final picker = ImagePicker();

  _ShowOrPickImageState(this.imageData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.memory(imageData)),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlatButton(
                onPressed: () => Navigator.pop(context, imageData),
                child: Text('Ok')),
            FlatButton(onPressed: pickImage, child: Text('Change')),
            FlatButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text('Cancel'))
          ],
        ),
      ),
    );
  }

  void pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final data = await pickedFile.readAsBytes();
      setState(() {
        imageData = data;
      });
    }
  }
}
