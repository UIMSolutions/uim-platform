/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.ports.repositories.points_of_interest;

import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:
interface PointOfInterestRepository : ITenantRepository!(PointOfInterest, PointOfInterestId) {
  PointOfInterest[] findByCategory(TenantId tenantId, PoiCategory category);
  PointOfInterest[] findByProvider(TenantId tenantId, string providerId);
}
