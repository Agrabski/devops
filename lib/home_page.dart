import 'package:devops/api/work.dart';
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
    // TODO: implement createState
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
        BottomNavigationBarItem(
            label: "Organisations", icon: Icon(Icons.business)),
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
        return organisations();
      case 1:
        return WorkList(_api, _work);
      case 2:
        return ProfileWidget(_account, _api.profile());
    }
    throw Exception("invalid index");
  }

  Widget organisations() {}

  void loadContent() {
    _work = null;
    loadWork();
    _api.getMe().then((value) => setState(() {
          _account = value;
        }));
    //throw Exception();
  }

  Future loadWork() async {
    try {
      var work = List<WorkItem>();
      var accounts = await _api.account().getAccounts(await _api.userId());
      for (var account in accounts)
        work.addAll(await _api.work().getMyWorkItems(account.accountName));
      setState(() {
        _work = work;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), gravity: ToastGravity.CENTER);
      setState(() {
        _work = List<WorkItem>();
      });
    }
  }
}
