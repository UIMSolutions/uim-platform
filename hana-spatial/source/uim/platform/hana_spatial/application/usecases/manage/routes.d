/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.application.usecases.manage.routes;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class ManageRoutesUseCase {
  private RouteRepository repo;

  this(RouteRepository repo) {
    this.repo = repo;
  }

  CommandResult calculateRoute(CalculateRouteRequest r) {
    auto err = SpatialValidator.validateCoordinate(r.originLat, r.originLon);
    if (err.length > 0) return CommandResult(false, "", "Origin: " ~ err);
    err = SpatialValidator.validateCoordinate(r.destinationLat, r.destinationLon);
    if (err.length > 0) return CommandResult(false, "", "Destination: " ~ err);
    err = SpatialValidator.validateId(r.id);
    if (err.length > 0) return CommandResult(false, "", err);

    auto route = Route(r.tenantId); //, r.createdBy);
    route.id = RouteId(r.id);
    route.origin = GeoCoordinate(r.originLat, r.originLon);
    route.destination = GeoCoordinate(r.destinationLat, r.destinationLon);
    route.originLabel = r.originLabel;
    route.destinationLabel = r.destinationLabel;
    route.providerId = r.providerId;
    route.language = r.language;

    
    try {
      route.travelMode = r.travelMode.to!TravelMode;
    } catch (Exception) {
      route.travelMode = TravelMode.car;
    }
    try {
      route.optimization = r.optimization.to!RouteOptimization;
    } catch (Exception) {
      route.optimization = RouteOptimization.fastest;
    }

    repo.save(route);
    return CommandResult(true, route.id.value, "");
  }

  Route getById(TenantId tenantId, string id) {
    return repo.findById(tenantId, RouteId(id));
  }

  Route[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto existing = repo.findById(tenantId, RouteId(id));
    if (existing.isNull)
      return CommandResult(false, "", "Route not found");
    repo.remove(tenantId, RouteId(id));
    return CommandResult(true, id, "");
  }
}
