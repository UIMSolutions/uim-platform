/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.services.subaccount;

import uim.platform.management;

mixin(ShowModule!());

@safe:

class SubaccountApi : ISubaccountApi {
  protected IManageSubaccountsUseCase usecase;

  this(IManageSubaccountsUseCase usecase) {
    this.usecase = usecase;
  }

  Json listSubaccounts(string tenantId, string globalAccountId, string directoryId, string region) {
    Subaccount[] items;
    if (directoryId.length > 0)
      items = usecase.listSubaccounts(tenant(tenantId), DirectoryId(directoryId));
    else if (globalAccountId.length > 0 && region.length > 0)
      items = usecase.listSubaccounts(tenant(tenantId), GlobalAccountId(globalAccountId), region);
    else if (globalAccountId.length > 0)
      items = usecase.listSubaccounts(tenant(tenantId), GlobalAccountId(globalAccountId));
    else
      items = usecase.listSubaccounts(tenant(tenantId));
    return collectionOf(items);
  }

  Json getSubaccount(string tenantId, string _id) {
    auto id = _id;
    return entityOrNotFound(usecase.getSubaccount(tenant(tenantId), SubaccountId(id)), "Subaccount");
  }
}
