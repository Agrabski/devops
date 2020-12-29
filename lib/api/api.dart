import 'dart:convert';
import 'dart:io';

import 'package:devops/api/project.dart';
import 'package:http/http.dart' as http;

import 'account.dart';

class Profile {
  final String id;
  final String displayName;
  static Profile fromJson(Map<String, dynamic> o) {
    return Profile(o['id'], o['displayName']);
  }

  Profile(this.id, this.displayName);
}

enum UrlType { App, Dev }

class AzureDevOpsApi {
  static final _defaultAppUrl = "https://app.vssps.visualstudio.com/";
  static final _defaultDevUrl = "https://dev.azure.com/";
  final String _AppUrl;
  final String _DevUrl;
  final String _personalAccessToken;

  String _userId;

  Future<T> makeGetApiCall<T>(
      String urlPath, T Function(dynamic) converter, UrlType type) async {
    var bytes = utf8.encode(":$_personalAccessToken");
    var token = base64.encode(bytes);
    if (urlPath.contains('?'))
      urlPath += '&';
    else
      urlPath += '?';
    urlPath += "api-version=6.0";
    var response = await http.get("${_getUrl(type)}$urlPath", headers: {
      HttpHeaders.authorizationHeader: "Basic $token",
    });
    if (response.statusCode == 200) {
      return converter((jsonDecode(response.body)));
    }
    throw Exception(
        "invalid return code! ${response.statusCode}, ${response.reasonPhrase}");
  }

  String _getUrl(UrlType type) {
    switch (type) {
      case UrlType.App:
        return _defaultAppUrl;
      case UrlType.Dev:
        return _defaultDevUrl;
    }
  }

  AzureDevOpsApi(this._personalAccessToken, this._AppUrl, this._DevUrl);
  static AzureDevOpsApi getDefault(String personalAccessToken) {
    return AzureDevOpsApi(personalAccessToken, _defaultAppUrl, _defaultDevUrl);
  }

  ProjectApi project() {
    return ProjectApi(this);
  }

  Future<Profile> getMe() {
    return makeGetApiCall<Profile>(
        '_apis/profile/profiles/me', (r) => Profile.fromJson(r), UrlType.App);
  }

  Future<String> userId() async {
    if (_userId == null) {
      _userId = await makeGetApiCall(
          "_apis/profile/profiles/{me}?api-version=6.0",
          (r) => r['id'] as String,
          UrlType.Dev);
    }
    return _userId;
  }

  AccountApi Account() {
    return AccountApi(this);
  }
}