import 'package:devops/api/api.dart';
import 'package:devops/api/profile.dart';
import 'package:devops/api/work.dart';
import 'package:devops/common/pick_string.dart';
import 'package:devops/user/select_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'edit_wrok_item.dart';

class WorkItemWidget extends StatefulWidget {
  final AzureDevOpsApi api;
  final WorkItem item;
  final void Function() loadWork;
  final void Function(WorkItem) delete;

  const WorkItemWidget(
      {Key key, this.api, this.item, this.loadWork, this.delete})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _WorkItemWidgetState(api, item, loadWork, delete);
  }
}

class _WorkItemWidgetState extends State<WorkItemWidget> {
  final AzureDevOpsApi _api;
  final WorkItem _item;
  final void Function() loadWork;
  final void Function(WorkItem) delete;

  _WorkItemWidgetState(this._api, this._item, this.loadWork, this.delete);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: _pickIcon(_item.fields['System.WorkItemType']),
            title: Text(_item.fields['System.Title']),
            subtitle: Column(
              children: [
                Text('State: ${_item.fields["System.State"]}'),
                Text('Assigned to: ${getAssignee(_item)}'),
                Text('Organization: ${_item.organisation}')
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('Reassign'),
                onPressed: () async {
                  var profiles =
                      await _api.profile().getProfileIdsFor(_item.organisation);
                  var user = await Navigator.push<ProfileReference>(context,
                      MaterialPageRoute(builder: (c) => SelectUser(profiles)));
                  try {
                    _api
                        .work()
                        .assignWorkItem(_item, user.name)
                        .then((value) => loadWork());
                  } catch (e) {}
                },
              ),
              const SizedBox(width: 8),
              TextButton(
                child: const Text('Change state'),
                onPressed: () {
                  changeIssueState(_item);
                },
              ),
              const SizedBox(width: 8),
              TextButton(
                child: const Text('Edit'),
                onPressed: () => edit(_item),
              ),
              const SizedBox(width: 8),
              TextButton(
                child: const Text('Delete'),
                onPressed: () => delete(_item),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Future changeIssueState(WorkItem item) async {
    var states = await _api.work().getIssueStates(
        item.organisation, item.project, item.fields['System.WorkItemType']);
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (c) => PickString(options: states)));

    if (result != null) {
      Fluttertoast.showToast(msg: 'Updating', gravity: ToastGravity.BOTTOM);

      await _api
          .work()
          .changeIssueState(item, result)
          .then((value) => loadWork());
    }
  }

  edit(WorkItem item) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => EditWorkItem(item: item, api: _api.work())));
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

  String getAssignee(WorkItem item) {
    var assignee = item?.fields['System.AssignedTo'];
    if (assignee == null) return "Unassigned";
    return assignee["displayName"];
  }
}
