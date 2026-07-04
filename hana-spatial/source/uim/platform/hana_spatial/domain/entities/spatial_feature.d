/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.entities.spatial_feature;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:

struct SpatialFeature {
  mixin TenantEntity!(SpatialFeatureId);

  SpatialLayerId layerId;
  string name;
  GeometryType geometryType;

  // GeoJSON geometry as JSON string
  string geometry;

  // Feature properties as JSON string
  string properties;

  BoundingBox boundingBox;
  string[][] tags;

  Json toJson() const {
    return entityToJson()
      .set("layerId", layerId.value)
      .set("name", name)
      .set("geometryType", geometryType.to!string)
      .set("geometry", geometry)
      .set("properties", properties)
      .set("boundingBox", boundingBox.toJson());
  }
}
