import 'package:devops/home_page.dart';
import 'package:devops/theme.dart';
import 'package:devops/theme/theme_change_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'theme/theme_change_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = await HydratedBlocDelegate.build();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static MyApp instance;
  MyApp() {
    instance = this;
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeChangeBloc>(
        create: (_) => ThemeChangeBloc(),
        child: BlocBuilder<ThemeChangeBloc, ThemeChangeState>(
            builder: (context, state) => MaterialApp(
                title: 'Flutter Demo',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: state.themeState.themeMode,
                home: HomePage())));
  }
}
