/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.entities.geocoding_result;

import uim.platform.hana_spatial;
mixin(ShowModule!());

@safe:

struct GeocodingResult {
  mixin TenantEntity!(GeocodingResultId);

  GeocodingType type;
  GeocodingMatchLevel matchLevel;
  double confidence;

  // Input
  string inputQuery;
  GeoCoordinate inputCoordinate;

  // Output
  GeoCoordinate coordinate;
  Address address;

  // Bounding box of result
  BoundingBox boundingBox;

  // Additional attributes
  string providerId;
  string language;
  string countryCode;

  Json toJson() const {
    return entityToJson()
      .set("type", type.to!string)
      .set("matchLevel", matchLevel.to!string)
      .set("confidence", confidence)
      .set("inputQuery", inputQuery)
      .set("coordinate", coordinate.toJson())
      .set("address", address.toJson())
      .set("boundingBox", boundingBox.toJson())
      .set("providerId", providerId)
      .set("language", language)
      .set("countryCode", countryCode);
  }
}
