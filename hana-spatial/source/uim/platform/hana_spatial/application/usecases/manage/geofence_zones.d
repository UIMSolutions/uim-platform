/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.application.usecases.manage.geofence_zones;

import uim.platform.hana_spatial;

import std.math : sqrt, PI, sin, cos, atan2;

// mixin(ShowModule!());

@safe:
class ManageGeofenceZonesUseCase {
  private GeofenceZoneRepository repo;

  this(GeofenceZoneRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateGeofenceZoneRequest r) {
    auto err = SpatialValidator.validateId(r.id);
    if (err.length > 0) return CommandResult(false, "", err);
    err = SpatialValidator.validateName(r.name);
    if (err.length > 0) return CommandResult(false, "", err);

    GeofenceZone zone;
    zone.initEntity(r.tenantId);
    zone.id = GeofenceZoneId(r.id);
    zone.name = r.name;
    zone.description = r.description;
    zone.centerCoordinate = GeoCoordinate(r.centerLat, r.centerLon);
    zone.radiusMeters = r.radiusMeters;
    zone.polygon = r.polygon;
    zone.active = r.active;
    zone.metadata = r.metadata;
    try {
      zone.shapeType = r.shapeType.to!GeofenceShapeType;
    } catch (Exception) {
      zone.shapeType = GeofenceShapeType.circle;
    }

    repo.save(zone);
    return CommandResult(true, zone.id.value, "");
  }

  CommandResult update(UpdateGeofenceZoneRequest r) {
    auto existing = repo.findById(r.tenantId, GeofenceZoneId(r.id));
    if (existing.isNull)
      return CommandResult(false, "", "Geofence zone not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.radiusMeters = r.radiusMeters;
    existing.polygon = r.polygon;
    existing.active = r.active;
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  // Simple Haversine-based point-in-circle check
  GeofenceCheckResult checkPoint(GeofenceCheckRequest r) {
    auto zone = repo.findById(r.tenantId, GeofenceZoneId(r.zoneId));
    if (zone.isNull)
      return GeofenceCheckResult(false, r.zoneId, "");

    bool inside = false;
    if (zone.shapeType == GeofenceShapeType.circle) {
      inside = isInsideCircle(
        zone.centerCoordinate.latitude, zone.centerCoordinate.longitude,
        zone.radiusMeters, r.latitude, r.longitude
      );
    }

    return GeofenceCheckResult(inside, zone.id.value, zone.name);
  }

  GeofenceZone getById(TenantId tenantId, string id) {
    return repo.findById(tenantId, GeofenceZoneId(id));
  }

  GeofenceZone[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto existing = repo.findById(tenantId, GeofenceZoneId(id));
    if (existing.isNull)
      return CommandResult(false, "", "Geofence zone not found");
    repo.remove(tenantId, GeofenceZoneId(id));
    return CommandResult(true, id, "");
  }

  private bool isInsideCircle(double centerLat, double centerLon, double radiusM,
    double pointLat, double pointLon) {
    enum double earthRadiusM = 6_371_000.0;
    double dLat = (pointLat - centerLat) * PI / 180.0;
    double dLon = (pointLon - centerLon) * PI / 180.0;
    double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(centerLat * PI / 180.0) * cos(pointLat * PI / 180.0) *
      sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distanceM = earthRadiusM * c;
    return distanceM <= radiusM;
  }
}
