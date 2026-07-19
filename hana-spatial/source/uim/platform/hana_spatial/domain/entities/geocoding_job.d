/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.entities.geocoding_job;

import uim.platform.hana_spatial;
mixin(ShowModule!());

@safe:

struct GeocodingJobItem {
  string externalRef;
  string inputAddress;
  GeoCoordinate resultCoordinate;
  GeocodingMatchLevel matchLevel;
  double confidence;
  string errorMessage;
  bool processed;

  Json toJson() const {
    return Json.emptyObject()
      .set("externalRef", externalRef)
      .set("inputAddress", inputAddress)
      .set("resultCoordinate", resultCoordinate.toJson())
      .set("matchLevel", matchLevel.to!string)
      .set("confidence", confidence)
      .set("errorMessage", errorMessage)
      .set("processed", processed);
  }
}

struct GeocodingJob {
  mixin TenantEntity!GeocodingJobId;

  string name;
  string description;
  SpatialJobStatus status;
  string providerId;
  string language;
  string countryCode;
  long totalItems;
  long processedItems;
  long failedItems;
  GeocodingJobItem[] items;

  Json toJson() const {
    auto itemsArr = Json.emptyArray;
    foreach (item; items) itemsArr ~= item.toJson();

    return entityToJson()
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string)
      .set("providerId", providerId)
      .set("language", language)
      .set("countryCode", countryCode)
      .set("totalItems", totalItems)
      .set("processedItems", processedItems)
      .set("failedItems", failedItems)
      .set("items", itemsArr);
  }
}
