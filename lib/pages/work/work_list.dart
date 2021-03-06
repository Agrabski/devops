import 'package:devops/api/api.dart';
import 'package:devops/api/project.dart';
import 'package:devops/api/work.dart';
import 'package:devops/common/multipleChoiceFilter.dart';
import 'package:devops/common/pick_string.dart';
import 'package:devops/pages/work/add_work_item.dart';
import 'package:devops/pages/work/edit_wrok_item.dart';
import 'package:devops/pages/work/work_item.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WorkList extends StatefulWidget {
  final AzureDevOpsApi _api;
  final List<WorkItem> _work;

  WorkList(this._api, this._work, {Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _WorkListState(_api, this._work);
  }
}

class _WorkListState extends State<WorkList>
    with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _animationController;
  final AzureDevOpsApi _api;
  static const List<String> _workItemTypes = [
    'Issue',
    'Task',
    'Bug',
    'Feature',
    'Epic'
  ];

  List<String> _selectedWorkItemTypes = _workItemTypes;
  List<String> _selectedStates;
  List<String> _assignees;
  List<String> _selectedAssignees;
  bool _doingWork = false;

  List<String> _allStates;

  String _titleFilter = '';
  String _organisationFilter = '';

  @override
  void initState() {
    if (_work != null) setupFilters();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  void setupFilters() {
    _selectedStates =
        _work.map((e) => e.fields['System.State'] as String).toSet().toList();
    _allStates = _selectedStates;
    _assignees = _work
        .map((e) => (e.fields['System.AssignedTo'] != null
            ? e.fields['System.AssignedTo']['displayName']
            : 'Unassigned') as String)
        .toSet()
        .toList();
    _selectedAssignees = List();
    _api.getMe().then(
        (value) => setState(() => _selectedAssignees = [value.displayName]));
  }

  List<WorkItem> _work;
  _WorkListState(this._api, this._work);

  bool _filter(WorkItem x) {
    return _selectedWorkItemTypes.contains(x.fields['System.WorkItemType']) &&
        _selectedStates.contains(x.fields['System.State']) &&
        (x.fields['System.Title'] as String)
            .toLowerCase()
            .contains(_titleFilter) &&
        x.organisation.toLowerCase().contains(_organisationFilter) &&
        _selectedAssignees.contains(x.fields['System.AssignedTo'] != null
            ? x.fields['System.AssignedTo']['displayName']
            : 'Unassigned');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: buildBody(), floatingActionButton: buildFloatingActionButton());
  }

  Widget buildFloatingActionButton() {
    if (_work == null) return null;
    return FloatingActionBubble(
      items: [
        Bubble(
          onPress: _showSearchDialog,
          icon: Icons.search_rounded,
          title: 'Search',
          iconColor: Colors.white,
          bubbleColor: Colors.blue,
        ),
        Bubble(
          onPress: () async {
            _animationController.reverse();
            addWork();
          },
          icon: Icons.add,
          title: 'Add',
          iconColor: Colors.white,
          bubbleColor: Colors.blue,
        )
      ],
      animation: _animation,
      onPress: () => _animationController.isCompleted
          ? _animationController.reverse()
          : _animationController.forward(),
      iconColor: Colors.blue,

      // Flaoting Action button Icon
      icon: AnimatedIcons.menu_arrow,
    );
  }

  Widget buildBody() {
    if (_work == null || _doingWork)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            new CircularProgressIndicator(),
            new Text("Loading content")
          ],
        ),
      );
    else
      return Center(
          child: Scrollbar(
              child: ListView(
        children: _work.where(_filter).map(makeWorkItem).toList(),
        shrinkWrap: true,
        padding: EdgeInsets.all(15),
      )));
  }

  String getAssignee(WorkItem item) {
    var assignee = item?.fields['System.AssignedTo'];
    if (assignee == null) return "Unassigned";
    return assignee["displayName"];
  }

  Widget makeWorkItem(WorkItem item) {
    return WorkItemWidget(
      api: _api,
      item: item,
      loadWork: loadWork,
      delete: delete,
    );
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
                  ),
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
                  TextFormField(
                    onChanged: (s) =>
                        setState(() => _organisationFilter = s.toLowerCase()),
                    decoration: InputDecoration(helperText: 'Organisation'),
                    initialValue: _organisationFilter,
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

    _animationController.reverse();
  }

  Future loadWork() async {
    _work = null;
    setState(() => _doingWork = true);
    var accounts = await _api.account().getAccounts(await _api.userId());
    for (var account in accounts)
      for (var w in await _api.work().getMyWorkItems(account.accountName)) {
        final v = await w;
        setState(() => (_work ?? (_work = List())).addAll(v));
        _doingWork = false;
      }
    setupFilters();
    Fluttertoast.showToast(msg: 'Done', gravity: ToastGravity.BOTTOM);
  }

  Future changeIssueState(WorkItem item) async {
    var states = await _api.work().getIssueStates(
        item.organisation, item.project, item.fields['System.WorkItemType']);
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (c) => PickString(options: states)));
    Fluttertoast.showToast(msg: 'Updating', gravity: ToastGravity.BOTTOM);
    if (result != null)
      await _api
          .work()
          .changeIssueState(item, result)
          .then((value) async => await loadWork());
  }

  edit(WorkItem item) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => EditWorkItem(item: item, api: _api.work())));
  }

  Future addWork() async {
    setState(() => _doingWork = true);
    var accounts = await _api.account().getAccounts(await _api.userId());
    var projects = List<TeamProjectReference>();
    for (var account in accounts) {
      projects.addAll(await _api.project().getProjects(account.accountName));
    }
    var item = await Navigator.push<WorkItem>(
        context,
        MaterialPageRoute(
            builder: (c) => NewWorkItem(
                  projects: projects,
                  api: _api,
                )));
    _work.add(item);
    setState(() {
      _doingWork = false;
    });
  }

  Future delete(WorkItem item) async {
    return _api.work().delete(item).then((value) => {
          setState(() => _work.remove(item)),
          Fluttertoast.showToast(msg: 'Deleted')
        });
  }
}
