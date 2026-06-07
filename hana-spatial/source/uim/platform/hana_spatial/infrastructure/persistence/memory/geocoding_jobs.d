/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.infrastructure.persistence.memory.geocoding_jobs;

import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:
class MemoryGeocodingJobRepository
  : TenantRepository!(GeocodingJob, GeocodingJobId),
    GeocodingJobRepository {

  GeocodingJob[] findByStatus(TenantId tenantId, SpatialJobStatus status) {
    GeocodingJob[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.status == status) results ~= item;
    }
    return results;
  }

  GeocodingJob[] findByProvider(TenantId tenantId, string providerId) {
    GeocodingJob[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.providerId == providerId) results ~= item;
    }
    return results;
  }
}
