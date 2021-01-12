import 'package:devops/api/api.dart';
import 'package:devops/api/project.dart';
import 'package:devops/api/work.dart';
import 'package:devops/common/pick_string.dart';
import 'package:devops/pages/canban_board.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProjectWidget extends StatefulWidget {
  final List<TeamProjectReference> projects;
  final AzureDevOpsApi api;
  final List<WorkItem> work;

  const ProjectWidget({Key key, this.projects, @required this.api, this.work})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ProjectWidget(projects, api, work);
  }
}

class _ProjectWidget extends State<ProjectWidget> {
  final List<TeamProjectReference> projects;
  final AzureDevOpsApi _api;
  final List<WorkItem> _work;
  bool _working = false;

  _ProjectWidget(this.projects, this._api, this._work);
  @override
  Widget build(BuildContext context) {
    var b = _working
        ? CircularProgressIndicator()
        : Scrollbar(
            child: ListView(
            children: projects.map(makeProject).toList(),
          ));
    return Scaffold(body: Center(child: b));
  }

  Widget makeProject(TeamProjectReference e) {
    return GestureDetector(
      child: Card(
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
      ),
      onTap: () async {
        setState(() {
          _working = true;
        });
        try {
          var boardsApi = _api.board();
          var boards = await boardsApi.getBoardNamesAndIds(
              organisation: e.organization, project: e.name);
          var name = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                  builder: (c) => PickString(
                        options: boards.map((x) => x.name).toList(),
                      )));
          var board = await boardsApi.getBoard(
              organisation: e.organization,
              project: e.name,
              id: boards.firstWhere((element) => element.name == name).id);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => CanbanBoard(
                      board: board,
                      teamName: e.name,
                      work: _work
                          .where((element) =>
                              element.organisation == e.organization &&
                              element.project == e.name)
                          .toList(),
                      api: _api)));
        } finally {
          setState(() => _working = false);
        }
      },
    );
  }
}
