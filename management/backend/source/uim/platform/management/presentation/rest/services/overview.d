/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.services.overview;

import uim.platform.management;

mixin(ShowModule!());

@safe:

class OverviewApi : IOverviewApi {
  protected IGetAccountOverviewUseCase usecase;

  this(IGetAccountOverviewUseCase usecase) {
    this.usecase = usecase;
  }

  Json getOverview(string tenantId, string globalAccountId = "") {
    if (globalAccountId.length > 0)
      return usecase.getOverview(tenant(tenantId), GlobalAccountId(globalAccountId)).toJson;
    return usecase.getTenantOverview(tenant(tenantId)).toJson;
  }
}
