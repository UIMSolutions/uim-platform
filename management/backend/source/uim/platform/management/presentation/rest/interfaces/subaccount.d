/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.interfaces.subaccount;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// vibe.d REST interface: subaccounts (tenant from the X-Tenant-ID header).
interface ISubaccountApi {
  /// GET /rest/v1/subaccounts
  @path("/subaccounts") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  @queryParam("globalAccountId", "globalAccountId")
  @queryParam("directoryId", "directoryId")
  @queryParam("region", "region")
  Json listSubaccounts(string tenantId, string globalAccountId = "", string directoryId = "", string region = "");

  /// GET /rest/v1/subaccounts/:id
  @path("/subaccounts/:id") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  Json getSubaccount(string tenantId, string _id);
}
