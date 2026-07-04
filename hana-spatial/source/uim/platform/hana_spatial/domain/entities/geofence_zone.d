/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.entities.geofence_zone;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:

struct GeofenceZone {
  mixin TenantEntity!(GeofenceZoneId);

  string name;
  string description;
  GeofenceShapeType shapeType;

  // Circle geofence
  GeoCoordinate centerCoordinate;
  double radiusMeters;

  // Polygon / BoundingBox geofence (GeoJSON polygon string)
  string polygon;

  BoundingBox boundingBox;
  bool active;
  string[][] metadata;

  Json toJson() const {
    return entityToJson()
      .set("name", name)
      .set("description", description)
      .set("shapeType", shapeType.to!string)
      .set("centerCoordinate", centerCoordinate.toJson())
      .set("radiusMeters", radiusMeters)
      .set("polygon", polygon)
      .set("boundingBox", boundingBox.toJson())
      .set("active", active);
  }
}
