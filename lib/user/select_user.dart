import 'package:devops/api/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectUser extends StatefulWidget {
  final List<ProfileReference> _profiles;

  const SelectUser(this._profiles, {Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _SelectUserState(_profiles);
  }
}

class _SelectUserState extends State<SelectUser> {
  final List<ProfileReference> _profiles;
  _SelectUserState(this._profiles);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: Text(_profiles[index].name),
          onTap: () => Navigator.pop(context, _profiles[index]),
        ),
        itemCount: _profiles.length,
      ),
    );
  }
}
