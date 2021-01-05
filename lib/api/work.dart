import 'package:devops/api/api.dart';

class WorkItem {
  final String organisation;
  final String project;
  final String url;
  final int rev;
  final int id;
  final Map<String, dynamic> fields;
  final WorkItemCommentVersionRef commentVersionRef;
  final ReferenceLinks _links;

  WorkItem(this.url, this.rev, this.id, this.fields, this.commentVersionRef,
      this._links, this.organisation, this.project);
  static WorkItem convert(
      Map<String, dynamic> e, String organisation, String project) {
    return WorkItem(
        e['url'],
        e['rev'],
        e['id'],
        e['fields'],
        e['commentVersionRef'],
        e['_links'],
        organisation,
        e['fields']['System.TeamProject']);
  }
}

class ReferenceLinks {
  final List<dynamic> links;

  ReferenceLinks(this.links);
}

class WorkItemCommentVersionRef {
  final int commentId;
  final int createdInRevision;
  final bool isDeleted;
  final String text;
  final String url;
  final int version;

  WorkItemCommentVersionRef(this.commentId, this.createdInRevision,
      this.isDeleted, this.text, this.url, this.version);
}

class WorkApi {
  final AzureDevOpsApi _api;

  WorkApi(this._api);

  static List<WorkItem> _convert(
      dynamic object, String organisation, String project) {
    return (object['value'] as Iterable<dynamic>)
        .map((x) => x as Map<dynamic, dynamic>)
        .map((k) =>
            WorkItem.convert(k as Map<String, dynamic>, organisation, project))
        .toList(growable: false);
  }

  Future<List<WorkItem>> getWorkItemBatch(
      String organisation, Iterable<int> ids,
      {String project}) {
    var path = organisation + '/';
    if (project != null) path += project + '/';

    path += '_apis/wit/workitemsbatch?api-version=6.0';
    return _api.makePostApiCall(
        path,
        (e) => _convert(e, organisation, e['System.TeamProject']),
        UrlType.Dev, {
      "ids": ids.toList(growable: false),
      "fields": [
        "System.Title",
        "System.WorkItemType",
        "Microsoft.VSTS.Scheduling.RemainingWork",
        "System.State",
        "System.TeamProject",
        "System.AssignedTo"
      ]
    },
        headers: {
          "Content-Type": "application/json"
        });
  }

  Future<List<WorkItem>> getMyWorkItems(String organisation,
      {String project, String team}) async {
    var path = organisation + '/';
    if (project != null) {
      path += project + '/';
      if (team != null) path += team + '/';
    }
    path += '_apis/wit/wiql?api-version=5.1';

    var ids = await _api.makePostApiCall(
        path,
        (e) => (e['workItems'] as Iterable<dynamic>).map((c) => c['id'] as int),
        UrlType.Dev,
        {'query': 'SELECT [System.Id] FROM workitem'},
        headers: {"Content-Type": "application/json"});
    var result = List<WorkItem>();
    while (ids.isNotEmpty) {
      // azure devops api only lets you take 200 work items at a time
      result.addAll(await getWorkItemBatch(organisation, ids.take(200),
          project: project));
      ids = ids.skip(200);
    }
    return result;
  }

  Future assignWorkItem(WorkItem item, String userName) async {
    return await _changeFieldValue(item, 'System.AssignedTo', userName);
  }

  Future _changeFieldValue(WorkItem item, String field, String value) async {
    return await _api.makePatchApiCall(
        '${item.organisation}/_apis/wit/workitems/${item.id}?api-version=6.0',
        (e) => null,
        UrlType.Dev, [
      {'op': 'add', 'path': '/fields/$field', 'value': value}
    ],
        headers: {
          "Content-Type": "application/json-patch+json"
        });
  }

  Future<List<String>> getIssueStates(
      String organisation, String project, String type) {
    return _api.makeGetApiCall(
        '$organisation/$project/_apis/wit/workitemtypes/$type/states?api-version=6.0-preview.1',
        (e) => (e['value'] as Iterable<dynamic>)
            .map((x) => x['name'] as String)
            .toList(),
        UrlType.Dev);
  }

  Future changeIssueState(WorkItem item, String newState) async {
    return await _changeFieldValue(item, 'System.State', newState);
  }
}
