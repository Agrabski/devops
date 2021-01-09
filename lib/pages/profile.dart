import 'dart:convert';
import 'dart:typed_data';

import 'package:devops/api/profile.dart';
import 'package:devops/common/show_or_pick_image.dart';
import 'package:devops/pages/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileWidget extends StatefulWidget {
  final Profile _account;
  final ProfileApi _api;
  ProfileWidget(this._account, this._api, {Key key}) : super(key: key);

  @override
  _ProfileWidgetState createState() {
    // TODO: implement createState
    return _ProfileWidgetState(this._account, this._api);
  }
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final Profile _account;
  final ProfileApi _api;

  Uint8List _imageBytes;

  @override
  void initState() {
    _imageBytes = base64Decode(_account.base64image);
    super.initState();
  }

  _ProfileWidgetState(this._account, this._api);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: GestureDetector(
                  child: Image.memory(_imageBytes),
                  onTap: changeProfilePicture,
                ),
                title: Text(_account.displayName),
                subtitle: Text(_account.id),
              ),
            ],
          ),
        ),
        InkWell(
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                )
              ],
            ),
          ),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (c) => Settings())),
        )
      ],
    );
  }

  void changeProfilePicture() async {
    var image = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ShowOrPickImage(initialImageData: _imageBytes)));
    if (image != null) {
      Fluttertoast.showToast(msg: 'Updating', gravity: ToastGravity.BOTTOM);
      _api.setAvatar(image, this._account.descriptor).then((x) =>
          Fluttertoast.showToast(msg: 'Done', gravity: ToastGravity.BOTTOM));
    }
  }
}
