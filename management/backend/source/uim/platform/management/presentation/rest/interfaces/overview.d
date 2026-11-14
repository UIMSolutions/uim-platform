/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.interfaces.overview;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// vibe.d REST interface: dashboard figures.
interface IOverviewApi {
  /// GET /rest/v1/overview[?globalAccountId=…]
  @path("/overview") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  @queryParam("globalAccountId", "globalAccountId")
  Json getOverview(string tenantId, string globalAccountId = "");
}
