/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.entities.point_of_interest;

import uim.platform.hana_spatial;
mixin(ShowModule!());

@safe:

struct PointOfInterest {
  mixin TenantEntity!(PointOfInterestId);

  string name;
  string description;
  PoiCategory category;
  GeoCoordinate coordinate;
  Address address;
  BoundingBox boundingBox;
  string phoneNumber;
  string website;
  string openingHours;
  double rating;
  long ratingCount;
  string providerId;
  string externalId;
  string[][] attributes;

  Json toJson() const {
    return entityToJson()
      .set("name", name)
      .set("description", description)
      .set("category", category.to!string)
      .set("coordinate", coordinate.toJson())
      .set("address", address.toJson())
      .set("boundingBox", boundingBox.toJson())
      .set("phoneNumber", phoneNumber)
      .set("website", website)
      .set("openingHours", openingHours)
      .set("rating", rating)
      .set("ratingCount", ratingCount)
      .set("providerId", providerId)
      .set("externalId", externalId);
  }
}
