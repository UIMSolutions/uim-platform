/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.services.global_account;

import uim.platform.management;

mixin(ShowModule!());

@safe:

class GlobalAccountApi : IGlobalAccountApi {
  protected IManageGlobalAccountsUseCase usecase;

  this(IManageGlobalAccountsUseCase usecase) {
    this.usecase = usecase;
  }

  Json listGlobalAccounts(string tenantId, string status) {
    auto items = status.length > 0 ? usecase.listAccounts(tenant(tenantId), status) : usecase.listAccounts(tenant(tenantId));
    return collectionOf(items);
  }

  Json getGlobalAccount(string tenantId, string _id) {
    auto id = _id;
    return entityOrNotFound(usecase.getAccount(tenant(tenantId), GlobalAccountId(id)), "GlobalAccount");
  }
}
