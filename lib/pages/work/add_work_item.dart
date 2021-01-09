import 'package:devops/api/api.dart';
import 'package:devops/api/project.dart';
import 'package:devops/api/work.dart';
import 'package:devops/pages/work/edit_wrok_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewWorkItem extends StatefulWidget {
  final List<TeamProjectReference> projects;
  final AzureDevOpsApi api;

  const NewWorkItem({Key key, @required this.projects, @required this.api})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NewWorkItemState(projects: projects, api: api);
  }
}

class _NewWorkItemState extends State<NewWorkItem> {
  final List<TeamProjectReference> projects;
  int _currentStep = 0;
  bool complete = false;
  final AzureDevOpsApi api;
  List<String> _issueTypes = List();
  String _issueType;
  TeamProjectReference _projectReference;

  _NewWorkItemState({this.projects, this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stepper(
      currentStep: _currentStep,
      onStepContinue: next,
      onStepTapped: (step) => goTo(step),
      onStepCancel: cancel,
      steps: [
        Step(
          state: StepState.editing,
          title: Text('Project'),
          content: DropdownButton(
              value: _projectReference,
              selectedItemBuilder: (c) =>
                  projects.map((e) => Text(e.name)).toList(),
              items: projects
                  .map((e) => DropdownMenuItem(
                        child: Text(e.name),
                        value: e,
                      ))
                  .toList(),
              onChanged: (e) async {
                setState(() => {_projectReference = e});
                var types = await api.project().getIssueTypes(e);
                setState(() => _issueTypes = types);
              }),
        ),
        Step(
          state: StepState.editing,
          title: Text('Issue type'),
          content: DropdownButton(
              value: _issueType,
              selectedItemBuilder: (c) =>
                  _issueTypes.map((e) => Text(e)).toList(),
              items: _issueTypes
                  .map((e) => DropdownMenuItem(
                        child: Text(e),
                        value: e,
                      ))
                  .toList(),
              onChanged: (e) => setState(() => _issueType = e)),
        ),
        Step(
            state: StepState.complete,
            title: Text('Save'),
            content: Text('Issue will be saved on the server'))
      ],
    ));
  }

  next() {
    if (_currentStep + 1 != 3)
      goTo(_currentStep + 1);
    else {
      var item = WorkItem(null, null, null, null, null, null,
          _projectReference.organization, this._projectReference.name);
      api
          .work()
          .create(item, _issueType)
          .then((o) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => EditWorkItem(item: o, api: api.work()))))
          .then((value) => Navigator.pop(context, value));
    }
  }

  cancel() {
    if (_currentStep > 0) {
      goTo(_currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => _currentStep = step);
  }
}
