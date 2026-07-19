/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.infrastructure.persistence.memory.geofence_zones;

import uim.platform.hana_spatial;
mixin(ShowModule!());

@safe:
class MemoryGeofenceZoneRepository
  : TenantRepository!(GeofenceZone, GeofenceZoneId),
    GeofenceZoneRepository {

  GeofenceZone[] findActive(TenantId tenantId) {
    GeofenceZone[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.active) results ~= item;
    }
    return results;
  }

  GeofenceZone[] findByShape(TenantId tenantId, GeofenceShapeType shape) {
    GeofenceZone[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.shapeType == shape) results ~= item;
    }
    return results;
  }
}
