import 'package:devops/api/api.dart';

class WorkItem {
  final String url;
  final int rev;
  final int id;
  final Map<String, dynamic> fields;
  final WorkItemCommentVersionRef commentVersionRef;
  final ReferenceLinks _links;

  WorkItem(this.url, this.rev, this.id, this.fields, this.commentVersionRef,
      this._links);
  static WorkItem fromJson(Map<String, dynamic> e) {
    return WorkItem(e['url'], e['rev'], e['id'], e['fields'],
        e['commentVersionRef'], e['_links']);
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

  static List<WorkItem> _convert(dynamic object) {
    return (object['value'] as Iterable<dynamic>)
        .map((x) => x as Map<dynamic, dynamic>)
        .map((k) => WorkItem.fromJson(k as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<WorkItem>> getWorkItemBatch(
      String organisation, Iterable<int> ids,
      {String project}) {
    var path = organisation + '/';
    if (project != null) path += project + '/';

    path += '_apis/wit/workitemsbatch?api-version=6.0';
    return _api.makePostApiCall(path, _convert, UrlType.Dev, {
      "ids": ids.toList(growable: false),
      "fields": [
        "System.Title",
        "System.WorkItemType",
        "Microsoft.VSTS.Scheduling.RemainingWork",
        "System.State"
      ]
    }, headers: {
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
    var x = List.from(ids);
    var result = List<WorkItem>();
    while (ids.isNotEmpty) {
      // azure devops api only lets you take 200 work items at a time
      result.addAll(await getWorkItemBatch(organisation, ids.take(200),
          project: project));
      ids = ids.skip(200);
    }
    return result;
  }
}
