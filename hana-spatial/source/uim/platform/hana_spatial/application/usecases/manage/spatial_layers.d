/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.application.usecases.manage.spatial_layers;

import uim.platform.hana_spatial;


mixin(ShowModule!());

@safe:
class ManageSpatialLayersUseCase {
  private SpatialLayerRepository repo;

  this(SpatialLayerRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateSpatialLayerRequest r) {
    auto err = SpatialValidator.validateId(r.id);
    if (err.length > 0) return CommandResult(false, "", err);
    err = SpatialValidator.validateName(r.name);
    if (err.length > 0) return CommandResult(false, "", err);

    auto layer = SpatialLayer(r.tenantId); //, UserId("test-user"));
    layer.id = SpatialLayerId(r.id);
    layer.name = r.name;
    layer.description = r.description;
    layer.coordinateSystem = r.coordinateSystem.length > 0 ? r.coordinateSystem : "WGS84";
    layer.isPublic = r.isPublic;
    layer.metadata = r.metadata;
    try {
      layer.type = r.type.to!SpatialLayerType;
    } catch (Exception) {
      layer.type = SpatialLayerType.mixed;
    }

    repo.save(layer);
    return CommandResult(true, layer.id.value, "");
  }

  CommandResult update(UpdateSpatialLayerRequest r) {
    auto existing = repo.findById(r.tenantId, SpatialLayerId(r.id));
    if (existing.isNull)
      return CommandResult(false, "", "Spatial layer not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.isPublic = r.isPublic;
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  SpatialLayer getById(TenantId tenantId, string id) {
    return repo.findById(tenantId, SpatialLayerId(id));
  }

  SpatialLayer[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto existing = repo.findById(tenantId, SpatialLayerId(id));
    if (existing.isNull)
      return CommandResult(false, "", "Spatial layer not found");
    repo.remove(tenantId, SpatialLayerId(id));
    return CommandResult(true, id, "");
  }
}
