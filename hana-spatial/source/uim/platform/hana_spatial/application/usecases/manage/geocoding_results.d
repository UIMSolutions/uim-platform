/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.application.usecases.manage.geocoding_results;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class ManageGeocodingResultsUseCase {
  private GeocodingResultRepository repo;

  this(GeocodingResultRepository repo) {
    this.repo = repo;
  }

  CommandResult geocodeAddress(GeocodeAddressRequest r) {
    auto err = SpatialValidator.validateAddress(r.address);
    if (err.length > 0)
      return CommandResult(false, "", err);

    err = SpatialValidator.validateId(r.id);
    if (err.length > 0)
      return CommandResult(false, "", err);

    auto result = GeocodingResult(r.tenantId, r.id, r.createdBy);
    result.type = GeocodingType.forward_;
    result.matchLevel = GeocodingMatchLevel.unknown;
    result.confidence = 0.0;
    result.inputQuery = r.address;
    result.language = r.language;
    result.countryCode = r.countryCode;
    result.providerId = r.providerId;

    repo.save(result);
    return CommandResult(true, result.id.value, "");
  }

  CommandResult reverseGeocode(ReverseGeocodeRequest r) {
    auto err = SpatialValidator.validateCoordinate(r.latitude, r.longitude);
    if (err.length > 0)
      return CommandResult(false, "", err);

    err = SpatialValidator.validateId(r.id);
    if (err.length > 0)
      return CommandResult(false, "", err);

     auto result = GeocodingResult(r.tenantId); //, r.createdBy);
    result.id = GeocodingResultId(r.id);
    result.type = GeocodingType.reverse_;
    result.matchLevel = GeocodingMatchLevel.unknown;
    result.confidence = 0.0;
    result.inputCoordinate = GeoCoordinate(r.latitude, r.longitude);
    result.providerId = r.providerId;

    repo.save(result);
    return CommandResult(true, result.id.value, "");
  }

  GeocodingResult getById(TenantId tenantId, string id) {
    return repo.findById(tenantId, GeocodingResultId(id));
  }

  GeocodingResult[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto existing = repo.findById(tenantId, GeocodingResultId(id));
    if (existing.isNull)
      return CommandResult(false, "", "Geocoding result not found");
    repo.remove(tenantId, GeocodingResultId(id));
    return CommandResult(true, id, "");
  }
}
