import 'dart:convert';
import 'dart:io';

import 'package:devops/api/profile.dart';
import 'package:devops/api/project.dart';
import 'package:devops/api/work.dart';
import 'package:http/http.dart' as http;

import 'account.dart';

enum UrlType { App, Dev, Vssps }

class AzureDevOpsApi {
  static final _defaultAppUrl = "https://app.vssps.visualstudio.com/";
  static final _defaultDevUrl = "https://dev.azure.com/";
  static final _defaultVsspsUrl = 'https://vssps.dev.azure.com/';
  final String _appUrl;
  final String _devUrl;
  final String _personalAccessToken;
  final String _vsspsUrl;

  String _userId;

  String _getToken() {
    var bytes = utf8.encode(":$_personalAccessToken");
    var token = base64.encode(bytes);
    return token;
  }

  Future<T> makeGetApiCall<T>(
      String urlPath, T Function(dynamic) converter, UrlType type) async {
    if (!urlPath.contains('api-version')) {
      if (urlPath.contains('?'))
        urlPath += '&';
      else
        urlPath += '?';
      urlPath += "api-version=6.0";
    }
    var response = await http.get("${_getUrl(type)}$urlPath", headers: {
      HttpHeaders.authorizationHeader: "Basic ${_getToken()}",
    });
    if (response.statusCode == 200) {
      return converter((jsonDecode(response.body)));
    }
    throw Exception(
        "invalid return code! ${response.statusCode}, ${response.reasonPhrase}");
  }

  Future<T> makePatchApiCall<T>(
      String urlPath, T Function(dynamic) converter, UrlType type, dynamic body,
      {Map<String, String> headers}) async {
    headers = headers ?? Map();
    headers[HttpHeaders.authorizationHeader] = "Basic ${_getToken()}";
    var response = await http.patch("${_getUrl(type)}$urlPath",
        headers: headers, body: jsonEncode(body));
    if (response.statusCode == 200) {
      return converter((jsonDecode(response.body)));
    }
    throw Exception(
        "invalid return code! ${response.statusCode}, ${response.reasonPhrase}");
  }

  Future<T> makePostApiCall<T>(String urlPath, T Function(dynamic) converter,
      UrlType type, Map<String, dynamic> body,
      {Map<String, String> headers}) async {
    headers = headers ?? Map();
    headers[HttpHeaders.authorizationHeader] = "Basic ${_getToken()}";
    var response = await http.post("${_getUrl(type)}$urlPath",
        headers: headers, body: jsonEncode(body));
    if (response.statusCode == 200) {
      return converter((jsonDecode(response.body)));
    }
    throw Exception(
        "invalid return code! ${response.statusCode}, ${response.reasonPhrase}");
  }

  String _getUrl(UrlType type) {
    switch (type) {
      case UrlType.App:
        return _appUrl;
      case UrlType.Dev:
        return _devUrl;
      case UrlType.Vssps:
        return _vsspsUrl;
    }
    throw Exception("invalid type: $type");
  }

  AzureDevOpsApi(
      this._personalAccessToken, this._appUrl, this._devUrl, this._vsspsUrl);
  static AzureDevOpsApi getDefault(String personalAccessToken) {
    return AzureDevOpsApi(
        personalAccessToken, _defaultAppUrl, _defaultDevUrl, _defaultVsspsUrl);
  }

  ProjectApi project() {
    return ProjectApi(this);
  }

  Future<Profile> getMe() {
    return makeGetApiCall<Profile>('_apis/profile/profiles/me?details=true',
        (r) => Profile.fromJson(r), UrlType.App);
  }

  Future<String> userId() async {
    if (_userId == null) {
      _userId = await makeGetApiCall(
          "_apis/profile/profiles/me?api-version=6.0",
          (r) => r['id'] as String,
          UrlType.App);
    }
    return _userId;
  }

  AccountApi account() {
    return AccountApi(this);
  }

  WorkApi work() {
    return WorkApi(this);
  }

  ProfileApi profile() {
    return ProfileApi(this);
  }

  Future makePutRequest(String urlPath, UrlType type,
      {dynamic body, Map<String, String> headers}) async {
    headers = headers ?? Map();
    headers[HttpHeaders.authorizationHeader] = "Basic ${_getToken()}";
    var response = await http.put("${_getUrl(type)}$urlPath",
        headers: headers, body: jsonEncode(body));
    if (response.statusCode != 200) {
      throw Exception(
          "invalid return code! ${response.statusCode}, ${response.reasonPhrase}");
    }
  }
}
