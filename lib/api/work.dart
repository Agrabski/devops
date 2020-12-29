class WorkItem {
  final String url;
  final int rev;
  final int id;
  final List<dynamic> fields;
  final WorkItemCommentVersionRef commentVersionRef;
  final ReferenceLinks _links;

  WorkItem(this.url, this.rev, this.id, this.fields, this.commentVersionRef,
      this._links);
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
