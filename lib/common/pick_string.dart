import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PickString extends StatelessWidget {
  final List<String> options;

  const PickString({Key key, this.options}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:
    Scrollbar(child: ListView.builder(itemBuilder: (context, index) => ListTile(
      title: Text(options[index]),
      onTap: () => Navigator.pop(context, options[index]),

    ),itemCount: options.length, )));
  }
}
