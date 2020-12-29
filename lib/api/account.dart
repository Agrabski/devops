import 'package:devops/api/api.dart';

class Account {
  final String accountId;
  final String accountName;
  final String accountOwner;
  final String organizationName;

  Account(this.accountId, this.accountName, this.accountOwner,
      this.organizationName);

  static Account fromJson(e) {}
  //todo: more attributes
}

class AccountApi {
  final AzureDevOpsApi _api;

  AccountApi(this._api);

  Future<List<Account>> getAccounts() async {
    return _api.makeGetApiCall(
        "_apis/accounts?memberId=${await _api.userId()}",
        (r) => List<Account>.from(
            (r['value'] as Iterable).map((e) => Account.fromJson(e))),
        UrlType.Dev);
  }
}
