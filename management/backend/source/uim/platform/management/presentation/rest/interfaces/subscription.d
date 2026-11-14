/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.interfaces.subscription;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// vibe.d REST interface: subscriptions (tenant from the X-Tenant-ID header).
interface ISubscriptionApi {
  /// GET /rest/v1/subscriptions
  @path("/subscriptions") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  @queryParam("subaccountId", "subaccountId")
  Json listSubscriptions(string tenantId, string subaccountId = "");

  /// GET /rest/v1/subscriptions/:id
  @path("/subscriptions/:id") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  Json getSubscription(string tenantId, string _id);
}
