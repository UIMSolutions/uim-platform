/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.application.usecases.manage.isolines;

import uim.platform.hana_spatial;


// mixin(ShowModule!());

@safe:
class ManageIsolinesUseCase {
  private IsolineRepository repo;

  this(IsolineRepository repo) {
    this.repo = repo;
  }

  CommandResult calculate(CalculateIsolineRequest r) {
    auto err = SpatialValidator.validateCoordinate(r.centerLat, r.centerLon);
    if (err.length > 0) return CommandResult(false, "", err);
    err = SpatialValidator.validateRangeValue(r.rangeValue);
    if (err.length > 0) return CommandResult(false, "", err);
    err = SpatialValidator.validateId(r.id);
    if (err.length > 0) return CommandResult(false, "", err);

    Isoline isoline;
    isoline.initEntity(r.tenantId);
    isoline.id = IsolineId(r.id);
    isoline.center = GeoCoordinate(r.centerLat, r.centerLon);
    isoline.rangeValue = r.rangeValue;
    isoline.providerId = r.providerId;
    try {
      isoline.mode = r.mode.to!IsolineMode;
    } catch (Exception) {
      isoline.mode = IsolineMode.time;
    }
    try {
      isoline.travelMode = r.travelMode.to!TravelMode;
    } catch (Exception) {
      isoline.travelMode = TravelMode.car;
    }

    repo.save(isoline);
    return CommandResult(true, isoline.id.value, "");
  }

  Isoline getById(TenantId tenantId, string id) {
    return repo.findById(tenantId, IsolineId(id));
  }

  Isoline[] list(TenantId tenantId) {
    return repo.find(tenantId);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto existing = repo.findById(tenantId, IsolineId(id));
    if (existing.isNull)
      return CommandResult(false, "", "Isoline not found");
    repo.remove(tenantId, IsolineId(id));
    return CommandResult(true, id, "");
  }
}
