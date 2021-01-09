import 'package:devops/api/api.dart';

enum ProjectState {
  all,
  createPending,
  deleted,
  deleting,
  isNew,
  unchanged,
  wellFormed,
}

enum ProjectVisibility { private, public }

class TeamProjectReference {
  final String abbreviation;
  final String defaultTeamImageUrl;
  final String id;
  final String lastUpdateTime;
  final String name;
  final int revision;
  final ProjectState state;
  final String url;
  final ProjectVisibility visibility;
  final String organization;

  static TeamProjectReference fromJson(Map<String, dynamic> o, String org) {
    return TeamProjectReference(
        null,
        o['defaultTeamImageUrl'],
        o['id'],
        o['lastUpdateTime'],
        o['name'],
        o['revision'],
        ProjectState.values.firstWhere(
            (element) => element.toString() == 'ProjectState.${o['state']}'),
        o['url'],
        ProjectVisibility.values.firstWhere((element) =>
            element.toString() == 'ProjectVisibility.${o['visibility']}'),
        org);
  }

  TeamProjectReference(
      this.abbreviation,
      this.defaultTeamImageUrl,
      this.id,
      this.lastUpdateTime,
      this.name,
      this.revision,
      this.state,
      this.url,
      this.visibility,
      this.organization);
}

class ProjectApi {
  final AzureDevOpsApi _api;

  ProjectApi(this._api);

  Future<List<TeamProjectReference>> getProjects(String organisation) {
    return _api.makeGetApiCall<List<TeamProjectReference>>(
        "$organisation/_apis/projects",
        (r) => List<TeamProjectReference>.from((r['value'] as Iterable)
            .map((e) => TeamProjectReference.fromJson(e, organisation))),
        UrlType.Dev);
  }

  Future<List<String>> getIssueTypes(TeamProjectReference project) {
    return _api.makeGetApiCall<List<String>>(
      '${project.organization}/${project.name}/_apis/wit/workitemtypes?api-version=6.0',
      (e) => (e['value'] as Iterable<dynamic>)
          .map((x) => x['name'] as String)
          .toList(),
      UrlType.Dev,
    );
  }
}
