/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.interfaces.service_plan;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// vibe.d REST interface: service-plans (tenant from the X-Tenant-ID header).
interface IServicePlanApi {
  /// GET /rest/v1/service-plans
  @path("/service-plans") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  @queryParam("serviceName", "serviceName")
  @queryParam("category", "category")
  @queryParam("region", "region")
  Json listServicePlans(string tenantId, string serviceName = "", string category = "", string region = "");

  /// GET /rest/v1/service-plans/:id
  @path("/service-plans/:id") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  Json getServicePlan(string tenantId, string _id);
}
