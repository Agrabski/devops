import 'dart:convert';
import 'dart:typed_data';

import 'package:devops/api/api.dart';

class Profile {
  final String id;
  final String displayName;
  final String url;
  final String uniqueName;
  final String base64image;
  final String descriptor;
  static Profile fromJson(Map<String, dynamic> o) {
    return Profile(o['id'], o['displayName'], o['url'], o['uniqueName'],
        o['coreAttributes']['Avatar']['value']['value'], o['descriptor']);
  }

  Profile(this.id, this.displayName, this.url, this.uniqueName,
      this.base64image, this.descriptor);
}

class ProfileReference {
  final String name;
  final String id;

  ProfileReference(this.name, this.id);
}

class ProfileApi {
  final AzureDevOpsApi _api;

  ProfileApi(this._api);

  Future<String> getProfileId(String graphId, String organisation) async {
    return await _api.makeGetApiCall(
        '$organisation/_apis/graph/storageKeys/$graphId?api-version=6.0-preview.1',
        (e) => e['value'] as String,
        UrlType.Vssps);
  }

  Future<List<ProfileReference>> getProfileIdsFor(String organisation) async {
    var graphIds = await _api.makeGetApiCall(
        '$organisation/_apis/graph/users?api-version=6.0-preview',
        (e) => (e['value'] as Iterable<dynamic>).toList(growable: false),
        UrlType.Vssps);
    return await Future.wait(graphIds
        .where((element) => element['domain'] == 'Windows Live ID')
        .map((id) async => ProfileReference(id['principalName'],
            await getProfileId(id['descriptor'] as String, organisation))));
  }

  Future setAvatar(Uint8List image, String descriptor) {
    return _api.makePutRequest(
        '_apis/graph/Subjects/$descriptor/avatars?api-version=6.0-preview.1',
        UrlType.Vssps,
        body: {
          'isAutoGenerated': false,
          'size': 'large',
          'timeStamp': DateTime.now().toString(),
          'value': base64Encode(image)
        });
  }
}
