/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.infrastructure.persistence.memory.routes;

import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:
class MemoryRouteRepository
  : TenantRepository!(Route, RouteId),
    RouteRepository {

  Route[] findByTravelMode(TenantId tenantId, TravelMode mode) {
    Route[] results;
    foreach (item; find(tenantId)) {
      if (item.travelMode == mode) results ~= item;
    }
    return results;
  }

  Route[] findByProvider(TenantId tenantId, string providerId) {
    Route[] results;
    foreach (item; find(tenantId)) {
      if (item.providerId == providerId) results ~= item;
    }
    return results;
  }
}
