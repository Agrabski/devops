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
  final String descripiton;
  final String id;
  final String lastUpdateTime;
  final String name;
  final int revision;
  final ProjectState state;
  final String url;
  final ProjectVisibility visibility;

  static TeamProjectReference fromJson(Map<String, dynamic> o) {
    return null;
  }

  TeamProjectReference(
      this.abbreviation,
      this.defaultTeamImageUrl,
      this.descripiton,
      this.id,
      this.lastUpdateTime,
      this.name,
      this.revision,
      this.state,
      this.url,
      this.visibility);
}

class ProjectApi {
  final AzureDevOpsApi _api;

  ProjectApi(this._api);

  Future<List<TeamProjectReference>> getProjects(String organisation) {
    return _api.makeGetApiCall<List<TeamProjectReference>>(
        "$organisation/_apis/projects",
        (r) => List<TeamProjectReference>.from((r['value'] as Iterable)
            .map((e) => TeamProjectReference.fromJson(e))),
        UrlType.Dev);
  }
}
