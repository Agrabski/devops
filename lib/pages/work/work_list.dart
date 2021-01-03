import 'package:devops/api/api.dart';
import 'package:devops/api/work.dart';
import 'package:devops/common/multiple_choice_filter/multipleChoiceFilter.dart';
import 'package:devops/user/select_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkList extends StatefulWidget {
  final List<WorkItem> _work;
  final WorkApi _api;

  WorkList(this._work, this._api, {Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WorkListState(_work, _api);
  }
}

class _WorkListState extends State<WorkList> {
  final WorkApi _api;
  static const List<String> _workItemTypes = [
    'Issue',
    'Task',
    'Bug',
    'Feature',
    'Epic'
  ];

  List<String> _selectedWorkItemTypes = _workItemTypes;
  List<String> _selectedStates;

  List<String> _allStates;

  @override
  void initState() {
    _selectedStates =
        _work.map((e) => e.fields['System.State'] as String).toSet().toList();
    _allStates = _selectedStates;
    super.initState();
  }

  final List<WorkItem> _work;
  _WorkListState(this._work, this._api);

  bool _filter(WorkItem x) {
    return _selectedWorkItemTypes.contains(x.fields['System.WorkItemType']) &&
        _selectedStates.contains(x.fields['System.State']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Scrollbar(
              child: ListView(
        children: _work.where(_filter).map(makeWorkItem).toList(),
        shrinkWrap: true,
        padding: EdgeInsets.all(15),
      ))),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSearchDialog,
        child: Icon(Icons.search_rounded),
      ),
    );
  }

  Widget makeWorkItem(WorkItem item) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: _pickIcon(item.fields['System.WorkItemType']),
            title: Text(item.fields['System.Title']),
            subtitle: Text('State: ${item.fields["System.State"]}'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('Reassign'),
                onPressed: () async {
                  var user = await Navigator.push<Profile>(
                      context, MaterialPageRoute(builder: (c) => SelectUser()));
                  try {
                    await _api.assignWorkItem(item, user);
                  } catch (e) {}
                },
              ),
              const SizedBox(width: 8),
              TextButton(
                child: const Text('Change state'),
                onPressed: () {/* ... */},
              ),
              const SizedBox(width: 8),
              TextButton(
                child: const Text('Edit'),
                onPressed: () {/* ... */},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Icon _pickIcon(String workitemType) {
    switch (workitemType) {
      case 'Issue':
        return Icon(
          Icons.assignment_outlined,
          color: Colors.yellow,
        );
      case 'Task':
        return Icon(Icons.assignment_late, color: Colors.green);
      case 'Bug':
        return Icon(Icons.adb, color: Colors.red);
      case 'Feature':
        return Icon(Icons.featured_video, color: Colors.purple);
      case 'Epic':
        return Icon(
          Icons.map,
          color: Colors.orange,
        );
      default:
        return Icon(Icons.error);
    }
  }

  void _showSearchDialog() {
    showDialog(
        context: context,
        useSafeArea: true,
        useRootNavigator: true,
        builder: (c) => AlertDialog(
              title: Text("Filter"),
              content: Container(
                child: Scrollbar(
                    child: ListView(children: [
                  MultipleChoiceFilter(
                    _workItemTypes,
                    _selectedWorkItemTypes,
                    onChoiceChanged: (x) =>
                        setState(() => _selectedWorkItemTypes = x),
                    title: "Issue type",
                  ),
                  MultipleChoiceFilter(
                    _allStates,
                    _selectedStates,
                    onChoiceChanged: (x) => setState(() => _selectedStates = x),
                    title: "Issue state",
                  )
                ])),
                height: 400,
                width: 300,
              ),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close"))
              ],
            ));
  }
}
