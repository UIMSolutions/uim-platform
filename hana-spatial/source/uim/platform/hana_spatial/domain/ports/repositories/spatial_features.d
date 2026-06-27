/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.ports.repositories.spatial_features;

import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:
interface SpatialFeatureRepository : ITentRepository!(SpatialFeature, SpatialFeatureId) {
  SpatialFeature[] findByLayer(TenantId tenantId, SpatialLayerId layerId);
  SpatialFeature[] findByGeometryType(TenantId tenantId, GeometryType geometryType);
}
