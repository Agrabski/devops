import 'package:devops/api/api.dart';
import 'package:devops/api/project.dart';
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
                var types = await api.project().getIssueTypes(e);
                setState(() => {_projectReference = e, _issueTypes = types});
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
      ],
    ));
  }

  next() {
    _currentStep + 1 != 2
        ? goTo(_currentStep + 1)
        : setState(() => complete = true);
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
