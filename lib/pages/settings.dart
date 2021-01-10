import 'package:devops/login.dart';
import 'package:devops/theme/theme_change_bloc.dart';
import 'package:devops/theme/theme_change_event.dart';
import 'package:devops/theme/theme_change_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../secrets.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Column(
          children: [
            InkWell(
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Remove token'),
                    )
                  ],
                ),
              ),
              onTap: () => removeApiKey().then((x) => Navigator.push(
                  context, MaterialPageRoute(builder: (c) => Login()))),
            ),
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Dark theme"),
                  BlocBuilder<ThemeChangeBloc, ThemeChangeState>(
                    builder: (context, state) {
                      return Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Switch(
                            value: !state.themeState.isLightMode,
                            onChanged: (value) =>
                                BlocProvider.of<ThemeChangeBloc>(context)
                                    .add(OnThemeChangedEvent(!value))),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        ));
  }
}
