/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.infrastructure.persistence.memory.geocoding_results;

import uim.platform.hana_spatial;
mixin(ShowModule!());

@safe:
class MemoryGeocodingResultRepository
  : TenantRepository!(GeocodingResult, GeocodingResultId),
    GeocodingResultRepository {

  GeocodingResult[] findByType(TenantId tenantId, GeocodingType type) {
    GeocodingResult[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.type == type) results ~= item;
    }
    return results;
  }

  GeocodingResult[] findByProvider(TenantId tenantId, string providerId) {
    GeocodingResult[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.providerId == providerId) results ~= item;
    }
    return results;
  }
}
