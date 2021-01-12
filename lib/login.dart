import 'package:devops/api/api.dart';
import 'package:devops/secrets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final TextEditingController _controller = TextEditingController();

  bool _canLogin = false;

  @override
  void initState() {
    _controller.addListener(() {
      setState(() => _canLogin = _controller.text.isNotEmpty);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Personal access token"),
          ),
          RaisedButton(
            onPressed: _canLogin ? _login : null,
            child: Text("Login"),
          )
        ],
      )),
    );
  }

  void _login() {
    storeApiKey(_controller.text).then((value) async =>
            AzureDevOpsApi.getDefault(await readApiKey())
                .getMe().catchError((e)=>{
                  Fluttertoast.showToast(msg: 'Error occurred, try again\n${e.toString()}')
                }).then((value) => Navigator.pop(context)));
  }
}
