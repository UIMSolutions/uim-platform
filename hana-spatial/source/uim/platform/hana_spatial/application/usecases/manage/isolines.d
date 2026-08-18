/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.application.usecases.manage.isolines;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class ManageIsolinesUseCase {
  protected IIsolineRepository repo;

  this(IIsolineRepository repo) {
    this.repo = repo;
  }

  UsecaseResult calculate(CalculateIsolineRequest r) {
    auto err = SpatialValidator.validateCoordinate(r.centerLat, r.centerLon);
    if (err.length > 0) return UsecaseResult(false, "", err);
    err = SpatialValidator.validateRangeValue(r.rangeValue);
    if (err.length > 0) return UsecaseResult(false, "", err);
    err = SpatialValidator.validateId(r.id);
    if (err.length > 0) return UsecaseResult(false, "", err);

    auto isoline = Isoline(r.tenantId, r.id.isNull ? IsolineId(createId()) : r.id, r.createdBy);
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
    return UsecaseResult(true, isoline.id.value, "");
  }

  Isoline getById(TenantId tenantId, string id) {
    return repo.findById(tenantId, IsolineId(id));
  }

  Isoline[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult remove(TenantId tenantId, string id) {
    auto existing = repo.findById(tenantId, IsolineId(id));
    if (existing.isNull)
      return UsecaseResult(false, "", "Isoline not found");
    repo.remove(tenantId, IsolineId(id));
    return UsecaseResult(true, id, "");
  }
}
