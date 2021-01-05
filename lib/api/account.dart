import 'package:devops/api/api.dart';

class Account {
  final String accountId;
  final String accountName;
  final String organizationName;

  Account({this.accountId, this.accountName, this.organizationName});

  static Account fromJson(e) {
    return Account(
        accountId: e['accountId'],
        accountName: e['accountName'],
        organizationName: e['organizationName']);
  }
  //todo: more attributes
}

class AccountApi {
  final AzureDevOpsApi _api;

  AccountApi(this._api);

  Future<List<Account>> getAccounts(String accountId) async {
    return _api.makeGetApiCall(
        "_apis/accounts?memberId=$accountId",
        (r) => List<Account>.from(
            (r['value'] as Iterable).map((e) => Account.fromJson(e))),
        UrlType.App);
  }
}
