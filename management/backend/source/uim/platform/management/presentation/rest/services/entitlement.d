/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.services.entitlement;

import uim.platform.management;

mixin(ShowModule!());

@safe:

class EntitlementApi : IEntitlementApi {
  protected IManageEntitlementsUseCase usecase;

  this(IManageEntitlementsUseCase usecase) {
    this.usecase = usecase;
  }

  Json listEntitlements(string tenantId, string globalAccountId, string subaccountId, string directoryId) {
    Entitlement[] items;
    if (subaccountId.length > 0)
      items = usecase.listEntitlements(tenant(tenantId), SubaccountId(subaccountId));
    else if (directoryId.length > 0)
      items = usecase.listEntitlements(tenant(tenantId), DirectoryId(directoryId));
    else if (globalAccountId.length > 0)
      items = usecase.listEntitlements(tenant(tenantId), GlobalAccountId(globalAccountId));
    else
      items = usecase.listEntitlements(tenant(tenantId));
    return collectionOf(items);
  }

  Json getEntitlement(string tenantId, string _id) {
    auto id = _id;
    return entityOrNotFound(usecase.getEntitlement(tenant(tenantId), EntitlementId(id)), "Entitlement");
  }
}
