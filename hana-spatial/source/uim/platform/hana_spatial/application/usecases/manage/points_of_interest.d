/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.application.usecases.manage.points_of_interest;

import uim.platform.hana_spatial;


// mixin(ShowModule!());

@safe:
class ManagePointsOfInterestUseCase {
  private PointOfInterestRepository repo;

  this(PointOfInterestRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreatePoiRequest r) {
    auto err = SpatialValidator.validateId(r.id);
    if (err.length > 0) return CommandResult(false, "", err);
    err = SpatialValidator.validateName(r.name);
    if (err.length > 0) return CommandResult(false, "", err);
    err = SpatialValidator.validateCoordinate(r.latitude, r.longitude);
    if (err.length > 0) return CommandResult(false, "", err);

    PointOfInterest poi;
    poi.initEntity(r.tenantId);
    poi.id = PointOfInterestId(r.id);
    poi.name = r.name;
    poi.description = r.description;
    poi.coordinate = GeoCoordinate(r.latitude, r.longitude);
    poi.address.street = r.street;
    poi.address.houseNumber = r.houseNumber;
    poi.address.city = r.city;
    poi.address.postalCode = r.postalCode;
    poi.address.country = r.country;
    poi.address.countryCode = r.countryCode;
    poi.phoneNumber = r.phoneNumber;
    poi.website = r.website;
    poi.openingHours = r.openingHours;
    poi.providerId = r.providerId;
    poi.externalId = r.externalId;
    poi.attributes = r.attributes;
    try {
      poi.category = r.category.to!PoiCategory;
    } catch (Exception) {
      poi.category = PoiCategory.other;
    }

    repo.save(poi);
    return CommandResult(true, poi.id.value, "");
  }

  CommandResult update(UpdatePoiRequest r) {
    auto existing = repo.find(r.tenantId, PointOfInterestId(r.id));
    if (existing.isNull)
      return CommandResult(false, "", "POI not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.coordinate = GeoCoordinate(r.latitude, r.longitude);
    existing.phoneNumber = r.phoneNumber;
    existing.website = r.website;
    existing.openingHours = r.openingHours;
    existing.updatedAt = currentTimestamp;
    try {
      existing.category = r.category.to!PoiCategory;
    } catch (Exception) {}

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  PointOfInterest getById(TenantId tenantId, string id) {
    return repo.findById(tenantId, PointOfInterestId(id));
  }

  PointOfInterest[] list(TenantId tenantId) {
    return repo.find(tenantId);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto existing = repo.findById(tenantId, PointOfInterestId(id));
    if (existing.isNull)
      return CommandResult(false, "", "POI not found");
    repo.remove(tenantId, PointOfInterestId(id));
    return CommandResult(true, id, "");
  }
}
