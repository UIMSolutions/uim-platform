/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.application.usecases.manage.spatial_features;

import uim.platform.hana_spatial;


// mixin(ShowModule!());

@safe:
class ManageSpatialFeaturesUseCase {
  private SpatialFeatureRepository repo;

  this(SpatialFeatureRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateSpatialFeatureRequest r) {
    auto err = SpatialValidator.validateId(r.id);
    if (err.length > 0) return CommandResult(false, "", err);
    err = SpatialValidator.validateLayer(r.layerId);
    if (err.length > 0) return CommandResult(false, "", err);

    SpatialFeature feature;
    feature.initEntity(r.tenantId);
    feature.id = SpatialFeatureId(r.id);
    feature.layerId = SpatialLayerId(r.layerId);
    feature.name = r.name;
    feature.geometry = r.geometry;
    feature.properties = r.properties;
    feature.tags = r.tags;
    try {
      feature.geometryType = r.geometryType.to!GeometryType;
    } catch (Exception) {
      feature.geometryType = GeometryType.point;
    }

    repo.save(feature);
    return CommandResult(true, feature.id.value, "");
  }

  CommandResult update(UpdateSpatialFeatureRequest r) {
    auto existing = repo.find(r.tenantId, SpatialFeatureId(r.id));
    if (existing.isNull)
      return CommandResult(false, "", "Spatial feature not found");

    existing.name = r.name;
    existing.geometry = r.geometry;
    existing.properties = r.properties;
    existing.tags = r.tags;
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  SpatialFeature getById(TenantId tenantId, string id) {
    return repo.findById(tenantId, SpatialFeatureId(id));
  }

  SpatialFeature[] list(TenantId tenantId) {
    return repo.find(tenantId);
  }

  SpatialFeature[] listByLayer(TenantId tenantId, string layerId) {
    return repo.findByLayer(tenantId, SpatialLayerId(layerId));
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto existing = repo.findById(tenantId, SpatialFeatureId(id));
    if (existing.isNull)
      return CommandResult(false, "", "Spatial feature not found");
    repo.remove(tenantId, SpatialFeatureId(id));
    return CommandResult(true, id, "");
  }
}
