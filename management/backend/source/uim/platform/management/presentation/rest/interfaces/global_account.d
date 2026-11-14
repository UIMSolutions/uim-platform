/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.interfaces.global_account;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// vibe.d REST interface: global-accounts (tenant from the X-Tenant-ID header).
interface IGlobalAccountApi {
  /// GET /rest/v1/global-accounts
  @path("/global-accounts") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  @queryParam("status", "status")
  Json listGlobalAccounts(string tenantId, string status = "");

  /// GET /rest/v1/global-accounts/:id
  @path("/global-accounts/:id") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  Json getGlobalAccount(string tenantId, string _id);
}
