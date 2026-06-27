/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.infrastructure.persistence.memory.spatial_features;

import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:
class MemorySpatialFeatureRepository
  : TentRepository!(SpatialFeature, SpatialFeatureId),
    SpatialFeatureRepository {

  SpatialFeature[] findByLayer(TenantId tenantId, SpatialLayerId layerId) {
    SpatialFeature[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.layerId.value == layerId.value) results ~= item;
    }
    return results;
  }

  SpatialFeature[] findByGeometryType(TenantId tenantId, GeometryType geometryType) {
    SpatialFeature[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.geometryType == geometryType) results ~= item;
    }
    return results;
  }
}
