/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.entities.data_product;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:

/// A data product provided by a DataProvider (e.g. a business object from S/4 HANA).
struct DataProduct {
  mixin TenantEntity!(DataProductId);

  DataProviderId providerId;
  string name;
  string description;
  DataProductStatus status;
  string schemaVersion;
  string namespace;         /// Object namespace / business domain
  AttributeSchema[] schema; /// Output schema attributes
  bool enabled;             /// Whether this product feeds into the composer
  long recordCount;
  long lastIngestedAt;
  string[string] metadata;

  Json toJson() const {
    auto schArr = Json.emptyArray;
    foreach (s; schema) {
      schArr ~= Json.emptyObject
        .set("name", s.name)
        .set("dataType", s.dataType)
        .set("required", s.required)
        .set("description", s.description);
    }

    return entityToJson()
      .set("providerId", providerId.value)
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string)
      .set("schemaVersion", schemaVersion)
      .set("namespace", namespace)
      .set("schema", schArr)
      .set("enabled", enabled)
      .set("recordCount", recordCount)
      .set("lastIngestedAt", lastIngestedAt);
  }
}
