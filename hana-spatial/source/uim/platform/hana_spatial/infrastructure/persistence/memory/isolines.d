/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.infrastructure.persistence.repositories.isolines;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class MemoryIsolineRepository
  : TenantRepository!(Isoline, IsolineId),
    IsolineRepository {

  Isoline[] findByMode(TenantId tenantId, IsolineMode mode) {
    Isoline[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.mode == mode) results ~= item;
    }
    return results;
  }

  Isoline[] findByProvider(TenantId tenantId, string providerId) {
    Isoline[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.providerId == providerId) results ~= item;
    }
    return results;
  }
}
