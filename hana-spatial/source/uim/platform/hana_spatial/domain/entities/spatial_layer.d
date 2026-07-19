/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.entities.spatial_layer;

import uim.platform.hana_spatial;
mixin(ShowModule!());

@safe:

struct SpatialLayer {
  mixin TenantEntity!SpatialLayerId;

  string name;
  string description;
  SpatialLayerType type;
  string coordinateSystem;
  BoundingBox extent;
  long featureCount;
  bool isPublic;
  string[][] metadata;

  Json toJson() const {
    return entityToJson()
      .set("name", name)
      .set("description", description)
      .set("type", type.to!string)
      .set("coordinateSystem", coordinateSystem)
      .set("extent", extent.toJson())
      .set("featureCount", featureCount)
      .set("isPublic", isPublic);
  }
}
