/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.interfaces.environment;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// vibe.d REST interface: environments (tenant from the X-Tenant-ID header).
interface IEnvironmentApi {
  /// GET /rest/v1/environments
  @path("/environments") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  @queryParam("subaccountId", "subaccountId")
  @queryParam("environmentType", "environmentType")
  Json listEnvironments(string tenantId, string subaccountId = "", string environmentType = "");

  /// GET /rest/v1/environments/:id
  @path("/environments/:id") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  Json getEnvironment(string tenantId, string _id);
}
