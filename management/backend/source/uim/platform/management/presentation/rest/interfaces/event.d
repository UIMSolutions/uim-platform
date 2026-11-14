/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.interfaces.event;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// vibe.d REST interface: events (tenant from the X-Tenant-ID header).
interface IEventApi {
  /// GET /rest/v1/events
  @path("/events") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  @queryParam("globalAccountId", "globalAccountId")
  @queryParam("subaccountId", "subaccountId")
  @queryParam("category", "category")
  @queryParam("severity", "severity")
  Json listEvents(string tenantId, string globalAccountId = "", string subaccountId = "", string category = "", string severity = "");

  /// GET /rest/v1/events/:id
  @path("/events/:id") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  Json getEvent(string tenantId, string _id);
}
