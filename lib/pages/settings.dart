import 'package:devops/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../secrets.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        InkWell(
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Remove token'),
                )
              ],
            ),
          ),
          onTap: () => removeApiKey().then((x) => Navigator.push(
              context, MaterialPageRoute(builder: (c) => Login()))),
        )
      ],
    ));
  }
}
