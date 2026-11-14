/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.services.service_plan;

import uim.platform.management;

mixin(ShowModule!());

@safe:

class ServicePlanApi : IServicePlanApi {
  protected IManageServicePlansUseCase usecase;

  this(IManageServicePlansUseCase usecase) {
    this.usecase = usecase;
  }

  Json listServicePlans(string tenantId, string serviceName, string category, string region) {
    ServicePlan[] items;
    if (serviceName.length > 0)
      items = usecase.listPlansByService(tenant(tenantId), serviceName);
    else if (category.length > 0)
      items = usecase.listPlansByCategory(tenant(tenantId), category);
    else if (region.length > 0)
      items = usecase.listPlansByRegion(tenant(tenantId), region);
    else
      items = usecase.listPlans(tenant(tenantId));
    return collectionOf(items);
  }

  Json getServicePlan(string tenantId, string _id) {
    auto id = _id;
    return entityOrNotFound(usecase.getPlan(tenant(tenantId), ServicePlanId(id)), "ServicePlan");
  }
}
