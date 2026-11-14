/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.interfaces.entitlement;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// vibe.d REST interface: entitlements (tenant from the X-Tenant-ID header).
interface IEntitlementApi {
  /// GET /rest/v1/entitlements
  @path("/entitlements") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  @queryParam("globalAccountId", "globalAccountId")
  @queryParam("subaccountId", "subaccountId")
  @queryParam("directoryId", "directoryId")
  Json listEntitlements(string tenantId, string globalAccountId = "", string subaccountId = "", string directoryId = "");

  /// GET /rest/v1/entitlements/:id
  @path("/entitlements/:id") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  Json getEntitlement(string tenantId, string _id);
}
