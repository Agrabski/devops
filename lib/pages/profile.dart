import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/api.dart';

class ProfileWidget extends StatefulWidget {
  final Profile _account;

  ProfileWidget(this._account, {Key key}) : super(key: key);

  @override
  _ProfileWidgetState createState() {
    // TODO: implement createState
    return _ProfileWidgetState(this._account);
  }
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final Profile _account;

  Uint8List _imageBytes;

  @override
  void initState() {
    _imageBytes = base64Decode(_account.base64image);
    super.initState();
  }

  _ProfileWidgetState(this._account);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Image.memory(_imageBytes),
                title: Text(_account.displayName),
                subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('BUY TICKETS'),
                    onPressed: () {/* ... */},
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    child: const Text('LISTEN'),
                    onPressed: () {/* ... */},
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
