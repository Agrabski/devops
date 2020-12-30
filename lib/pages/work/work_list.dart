import 'package:devops/api/work.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkList extends StatefulWidget {
  final List<WorkItem> _work;

  const WorkList(this._work, {Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WorkListState(_work);
  }
}

class _WorkListState extends State<WorkList> {
  final List<WorkItem> _work;
  _WorkListState(this._work);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search_rounded),
      ),
    );
  }
}
