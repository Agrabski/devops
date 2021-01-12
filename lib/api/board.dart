import 'package:devops/api/api.dart';
import 'package:flutter/cupertino.dart';

class Board {
  final String name;
  final List<BoardColumn> columns;

  Board(this.columns, this.name);

  static Board fromJson(dynamic e) {
    return Board(
      (e['columns'] as Iterable<dynamic>)
          .map((x) => BoardColumn(
              x['id'],
              x['name'],
              (x['stateMappings'] as Map<String, dynamic>)
                  .cast<String, String>()))
          .toList(),
      e['name'],
    );
  }
}

class BoardReference {
  final String id;
  final String name;

  BoardReference(this.id, this.name);
}

class BoardColumn {
  final String id;
  final String name;
  final Map<String, String> stateMappings;

  BoardColumn(this.id, this.name, this.stateMappings);
}

class BoardApi {
  final AzureDevOpsApi _api;

  BoardApi(this._api);

  Future<Board> getBoard(
      {@required String organisation,
      @required String project,
      @required String id}) {
    return _api.makeGetApiCall(
        '$organisation/$project/_apis/work/boards/$id?api-version=6.0',
        (e) => Board.fromJson(e),
        UrlType.Dev);
  }

  Future<List<BoardReference>> getBoardNamesAndIds({
    @required String organisation,
    @required String project,
  }) {
    return _api.makeGetApiCall(
        '$organisation/$project/_apis/work/boards?api-version=6.0',
        (e) => (e['value'] as Iterable<dynamic>)
            .map((x) => BoardReference(x['id'], x['name']))
            .toList(),
        UrlType.Dev);
  }
}
