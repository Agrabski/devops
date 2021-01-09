import 'package:devops/api/project.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProjectWidget extends StatefulWidget {
  final List<TeamProjectReference> projects;

  const ProjectWidget({Key key, this.projects}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ProjectWidget(projects);
  }
}

class _ProjectWidget extends State<ProjectWidget> {
  final List<TeamProjectReference> projects;

  _ProjectWidget(this.projects);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Scrollbar(
      child: ListView(
        children: projects.map(makeProject).toList(),
      ),
    )));
  }

  Widget makeProject(TeamProjectReference e) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: e.defaultTeamImageUrl != null
                ? Image.network(e.defaultTeamImageUrl)
                : Icon(Icons.business),
            title: Text(e.name),
            subtitle: Column(
              children: [Text('Organization: ${e.organization}')],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
          ),
        ],
      ),
    );
  }
}
