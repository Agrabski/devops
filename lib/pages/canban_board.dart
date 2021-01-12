import 'package:devops/api/api.dart';
import 'package:devops/api/board.dart';
import 'package:devops/api/work.dart';
import 'package:devops/common/multipleChoiceFilter.dart';
import 'package:devops/pages/work/work_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CanbanBoard extends StatefulWidget {
  final Board board;
  final String teamName;
  final List<WorkItem> work;
  final AzureDevOpsApi api;

  const CanbanBoard(
      {Key key,
      @required this.board,
      @required this.teamName,
      this.work,
      this.api})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _CanbanBoardState(board, teamName, work, api);
  }
}

class _CanbanBoardState extends State<CanbanBoard> {
  final AzureDevOpsApi _api;
  Board _board;
  final List<WorkItem> _work;
  final String _teamName;
  List<String> _assignees;
  List<String> _selectedAssignees;
  String _titleFilter = '';

  @override
  void initState() {
    _assignees = _work
        .map((e) => (e.fields['System.AssignedTo'] != null
            ? e.fields['System.AssignedTo']['displayName']
            : 'Unassigned') as String)
        .toSet()
        .toList();
    _selectedAssignees = List();
    _api.getMe().then(
        (value) => setState(() => _selectedAssignees = [value.displayName]));
    super.initState();
  }

  _CanbanBoardState(this._board, this._teamName, this._work, this._api);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _board.columns.length,
      child: Scaffold(
        body: TabBarView(
          children: _board.columns
              .map((e) => Scrollbar(
                      child: ListView(
                    children: _work
                        .where((element) =>
                            element.fields['System.State'] == e.name &&
                            _board.columns.any((k) => k.stateMappings
                                .containsKey(
                                    element.fields['System.WorkItemType'])))
                        .where(_filter)
                        .map(_makeWorkItem)
                        .toList(),
                  )))
              .toList(),
        ),
        appBar: AppBar(
          title: Text(_teamName),
          bottom: TabBar(
              isScrollable: true,
              tabs: _board.columns
                  .map((e) => Tab(
                        text: e.name,
                      ))
                  .toList()),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search_rounded),
          onPressed: _showSearchDialog,
        ),
      ),
    );
  }

  Widget _makeWorkItem(WorkItem item) {
    return WorkItemWidget(
      api: _api,
      item: item,
      loadWork: loadWork,
      delete: delete,
    );
  }

  String getAssignee(WorkItem item) {
    var assignee = item?.fields['System.AssignedTo'];
    if (assignee == null) return "Unassigned";
    return assignee["displayName"];
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
                    _assignees,
                    _selectedAssignees,
                    onChoiceChanged: (x) =>
                        setState(() => _selectedAssignees = x),
                    title: "Assignee",
                  ),
                  TextFormField(
                    onChanged: (s) =>
                        setState(() => _titleFilter = s.toLowerCase()),
                    decoration: InputDecoration(helperText: 'Title'),
                    initialValue: _titleFilter,
                  ),
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

  Future delete(WorkItem item) async {
    return _api.work().delete(item).then((value) => {
          setState(() => _work.remove(item)),
          Fluttertoast.showToast(msg: 'Deleted')
        });
  }

  Future loadWork() async {
    _work.clear();
    var accounts = await _api.account().getAccounts(await _api.userId());
    for (var account in accounts)
      for (var w in await _api.work().getMyWorkItems(account.accountName)) {
        final v = await w;
        setState(() => _work.addAll(v));
      }
    Fluttertoast.showToast(msg: 'Done', gravity: ToastGravity.BOTTOM);
  }

  bool _filter(WorkItem x) {
    return (x.fields['System.Title'] as String)
            .toLowerCase()
            .contains(_titleFilter) &&
        _selectedAssignees.contains(x.fields['System.AssignedTo'] != null
            ? x.fields['System.AssignedTo']['displayName']
            : 'Unassigned');
  }
}
