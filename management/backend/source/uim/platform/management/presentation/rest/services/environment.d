/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.services.environment;

import uim.platform.management;

mixin(ShowModule!());

@safe:

class EnvironmentApi : IEnvironmentApi {
  protected IManageEnvironmentsUseCase usecase;

  this(IManageEnvironmentsUseCase usecase) {
    this.usecase = usecase;
  }

  Json listEnvironments(string tenantId, string subaccountId, string environmentType) {
    Environment[] items;
    if (subaccountId.length > 0 && environmentType.length > 0)
      items = usecase.listEnvironments(tenant(tenantId), SubaccountId(subaccountId), environmentType);
    else if (subaccountId.length > 0)
      items = usecase.listEnvironments(tenant(tenantId), SubaccountId(subaccountId));
    else
      items = usecase.listEnvironments(tenant(tenantId));
    return collectionOf(items);
  }

  Json getEnvironment(string tenantId, string _id) {
    auto id = _id;
    return entityOrNotFound(usecase.getEnvironment(tenant(tenantId), EnvironmentId(id)), "Environment");
  }
}
