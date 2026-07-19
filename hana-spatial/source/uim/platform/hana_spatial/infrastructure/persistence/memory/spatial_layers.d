/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.infrastructure.persistence.memory.spatial_layers;

import uim.platform.hana_spatial;
mixin(ShowModule!());

@safe:
class MemorySpatialLayerRepository
  : TenantRepository!(SpatialLayer, SpatialLayerId),
    SpatialLayerRepository {

  SpatialLayer[] findByType(TenantId tenantId, SpatialLayerType type) {
    SpatialLayer[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.type == type) results ~= item;
    }
    return results;
  }

  SpatialLayer[] findPublic(TenantId tenantId) {
    SpatialLayer[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.isPublic) results ~= item;
    }
    return results;
  }
}
