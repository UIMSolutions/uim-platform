/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.infrastructure.persistence.memory.points_of_interest;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class MemoryPointOfInterestRepository
  : TenantRepository!(PointOfInterest, PointOfInterestId),
    PointOfInterestRepository {

  PointOfInterest[] findByCategory(TenantId tenantId, PoiCategory category) {
    PointOfInterest[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.category == category) results ~= item;
    }
    return results;
  }

  PointOfInterest[] findByProvider(TenantId tenantId, string providerId) {
    PointOfInterest[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.providerId == providerId) results ~= item;
    }
    return results;
  }
}
