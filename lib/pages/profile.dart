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
  const ProfileWidget(this._account, this._api, {Key key}) : super(key: key);

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
    if (_account != null) _imageBytes = base64Decode(_account.base64image);
    super.initState();
  }

  _ProfileWidgetState(this._account, this._api);

  @override
  Widget build(BuildContext context) {
    var children = List<Widget>();
    children.add(Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: GestureDetector(
              child: _account != null
                  ? Image.memory(_imageBytes)
                  : CircularProgressIndicator(),
              onTap: changeProfilePicture,
            ),
            title: Text(_account?.displayName ?? "Account name"),
            subtitle: Text(_account?.id ?? "Account id"),
          ),
        ],
      ),
    ));
    children.add(InkWell(
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
    ));
    return Column(children: children);
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
