/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.entities.isoline;

import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:

struct Isoline {
  mixin TenantEntity!(IsolineId);

  GeoCoordinate center;
  IsolineMode mode;
  double rangeValue;       // seconds (time mode) or meters (distance mode)
  TravelMode travelMode;

  // GeoJSON Polygon as JSON string representing the reachable area
  string polygon;

  BoundingBox boundingBox;
  string providerId;

  Json toJson() const {
    return entityToJson()
      .set("center", center.toJson())
      .set("mode", mode.to!string)
      .set("rangeValue", rangeValue)
      .set("travelMode", travelMode.to!string)
      .set("polygon", polygon)
      .set("boundingBox", boundingBox.toJson())
      .set("providerId", providerId);
  }
}
