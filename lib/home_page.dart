import 'package:devops/api/work.dart';
import 'package:devops/pages/work/work_list.dart';
import 'package:devops/secrets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'api/api.dart';
import 'login.dart';
import 'pages/profile.dart';

//wq7upwrwyjuuhq6mxojfz2eekrtw77dbt34yls4wfvuan2b5utgq
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  bool _hasApiKey = false;
  bool _contentReady = false;
  int _currentIndex = 0;
  AzureDevOpsApi _api;

  Profile _account;
  List<WorkItem> _work;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 5))
        .then((value) => apiKeyExists().then((value) => {
              setState(() => _hasApiKey = value),
              if (!value)
                Navigator.push(
                        context, MaterialPageRoute(builder: (c) => Login()))
                    .then((_) => readApiKey().then((key) =>
                        {_api = AzureDevOpsApi.getDefault(key), loadContent()}))
              else
                readApiKey().then((key) =>
                    {_api = AzureDevOpsApi.getDefault(key), loadContent()})
            }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (_hasApiKey && _contentReady) {
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
      title: Text("Azure DevOps"),
    );
  }

  Widget buildBottomBar() {
    var bar = BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            label: "Organisations", icon: Icon(Icons.business)),
        BottomNavigationBarItem(label: "My work", icon: Icon(Icons.work)),
        BottomNavigationBarItem(label: "Profile", icon: Icon(Icons.person))
      ],
      onTap: (i) =>
          {if (_hasApiKey && _contentReady) setState(() => _currentIndex = i)},
      currentIndex: _currentIndex,
    );
    if (_hasApiKey && _contentReady) return bar;
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
        return organisations();
      case 1:
        return WorkList(null);
      case 2:
        return ProfileWidget(_account);
    }
    throw Exception("invalid index");
  }

  Widget organisations() {}

  void loadContent() {
    _api.getMe().then((value) => setState(() {
          _account = value;
          _contentReady = true;
        }));
    _api.work().getWorkItems().then((value) => setState(() => _work = value));
  }
}
