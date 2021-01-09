import 'package:devops/api/work.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html_editor/html_editor.dart';

class EditWorkItem extends StatefulWidget {
  final WorkItem item;
  final WorkApi api;

  const EditWorkItem({Key key, this.item, this.api}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditWorkItemState(item, api);
  }
}

class _EditWorkItemState extends State<EditWorkItem> {
  WorkItem item;
  final WorkApi api;
  GlobalKey<HtmlEditorState> _descriptionKey = GlobalKey();
  TextEditingController _nameController;
  TextEditingController _remainingWorkController;
  TextEditingController _effort;

  _EditWorkItemState(this.item, this.api) {
    _nameController = TextEditingController(text: item.fields['System.Title']);
    _remainingWorkController = TextEditingController(
        text: item.fields['Microsoft.VSTS.Scheduling.RemainingWork']
                ?.toString() ??
            '');
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text('Issue ${item.id}'),
                IconButton(icon: Icon(Icons.save), onPressed: saveWorkItem)
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
          body: Scrollbar(
            child: ListView(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(helperText: 'Title'),
                ),
                Column(children: [
                  Text('Description:'),
                  HtmlEditor(
                    key: _descriptionKey,
                    value: item.fields['System.Description'],
                  )
                ]),
                TextField(
                  controller: _remainingWorkController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(helperText: 'Remaining work'),
                ),
              ],
            ),
          ),
        ));
  }

  Future<Map<String, String>> getChangedFields() async {
    var changedFields = Map<String, String>();
    var description = _descriptionKey.currentState.getText();

    if (_nameController.text != item.fields['System.Title'])
      changedFields['/fields/System.Title'] = _nameController.text;

    if (await description != item.fields['System.Description'])
      changedFields['/fields/System.Description'] = await description;

    if (_remainingWorkController.text !=
        (item.fields['Microsoft.VSTS.Scheduling.RemainingWork']?.toString() ??
            ''))
      changedFields['/fields/Microsoft.VSTS.Scheduling.RemainingWork'] =
          _remainingWorkController.text;
    return changedFields;
  }

  Future saveWorkItem() async {
    var changedFields = await getChangedFields();

    if (changedFields.isNotEmpty) {
      try {
        await api.changeFieldValues(this.item, changedFields);
        var i = await api.getWorkItem(item.id, item.organisation);
        setState(() => item = i);
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  Future<bool> onWillPop() async {
    var changes = await getChangedFields();
    if (changes.isNotEmpty) {
      return showDialog(
            context: context,
            child: new AlertDialog(
              title: new Text('Do you want to quit?'),
              content: new Text('You have unsaved changes.'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text('No'),
                ),
                new FlatButton(
                  onPressed: () => saveWorkItem()
                      .then((value) => Navigator.of(context).pop(true)),
                  child: new Text('Save'),
                ),
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: new Text('Yes'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return Future.value(true);
  }
}
