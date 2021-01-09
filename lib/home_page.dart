import 'package:devops/api/project.dart';
import 'package:devops/api/work.dart';
import 'package:devops/pages/project.dart';
import 'package:devops/pages/work/work_list.dart';
import 'package:devops/secrets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'api/api.dart';
import 'api/profile.dart';
import 'login.dart';
import 'pages/profile.dart';

//wq7upwrwyjuuhq6mxojfz2eekrtw77dbt34yls4wfvuan2b5utgq
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  bool _hasApiKey = false;
  bool _contentReady() => _work != null;
  int _currentIndex = 0;

  AzureDevOpsApi _api;

  Profile _account;
  List<WorkItem> _work;
  List<TeamProjectReference> _projects;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 5))
        .then((value) => apiKeyExists().then((value) => {
              setState(() => _hasApiKey = value),
              if (!value)
                Navigator.push(
                        context, MaterialPageRoute(builder: (c) => Login()))
                    .then((_) => readApiKey().then((key) => {
                          _hasApiKey = true,
                          _api = AzureDevOpsApi.getDefault(key),
                          loadContent()
                        }))
              else
                readApiKey().then((key) => {
                      _hasApiKey = true,
                      _api = AzureDevOpsApi.getDefault(key),
                      loadContent()
                    })
            }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasApiKey && _contentReady()) {
      return Scaffold(
        appBar: bar(),
        body: buildBody(),
        bottomNavigationBar: buildBottomBar(),
      );
    } else
      return Scaffold(
        appBar: bar(),
        body: buildSpinner(),
        bottomNavigationBar: buildBottomBar(),
      );
  }

  AppBar bar() {
    return AppBar(
      title: Row(
        children: [
          Text("Azure DevOps"),
          IconButton(icon: Icon(Icons.refresh), onPressed: () => loadContent())
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  Widget buildBottomBar() {
    var bar = BottomNavigationBar(
      items: [
        BottomNavigationBarItem(label: "Projects", icon: Icon(Icons.business)),
        BottomNavigationBarItem(label: "My work", icon: Icon(Icons.work)),
        BottomNavigationBarItem(label: "Profile", icon: Icon(Icons.person))
      ],
      onTap: (i) => {
        if (_hasApiKey && _contentReady()) setState(() => _currentIndex = i)
      },
      currentIndex: _currentIndex,
    );
    if (_hasApiKey && _contentReady()) return bar;
    return Theme(
        child: bar,
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ));
  }

  Widget buildSpinner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          new CircularProgressIndicator(),
          new Text(_hasApiKey ? "Loading content" : "Fetching credentials")
        ],
      ),
    );
  }

  Widget buildBody() {
    switch (_currentIndex) {
      case 0:
        return projects();
      case 1:
        return WorkList(_api, _work);
      case 2:
        return ProfileWidget(_account, _api.profile());
    }
    throw Exception("invalid index");
  }

  Widget projects() {
    return _projects != null
        ? ProjectWidget(projects: _projects)
        : Center(child: CircularProgressIndicator());
  }

  void loadContent() {
    setState(() => _work = null);
    loadWork();
    _api.getMe().then((value) => setState(() {
          _account = value;
        }));
    //throw Exception();
  }

  Future loadWork() async {
    try {
      var projects = List<TeamProjectReference>();
      var accounts = await _api.account().getAccounts(await _api.userId());
      for (var account in accounts) {
        for (var w in await _api.work().getMyWorkItems(account.accountName)) {
          final v = await w;
          if (v.isNotEmpty)
            setState(() => (_work == null ? _work = List() : _work).addAll(v));
        }
        var p = await _api.project().getProjects(account.accountName);
        projects.addAll(p);
        setState(() => _projects = projects);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), gravity: ToastGravity.CENTER);
      setState(() {
        _work = List<WorkItem>();
      });
    }
  }
}
