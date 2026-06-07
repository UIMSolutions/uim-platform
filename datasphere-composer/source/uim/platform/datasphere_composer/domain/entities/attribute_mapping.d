/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.entities.attribute_mapping;

import uim.platform.datasphere_composer;

// mixin(ShowModule!());

@safe:

/// Maps source data product schema attributes to the output composer schema attributes.
struct AttributeMapping {
  mixin TenantEntity!(AttributeMappingId);

  DataSourceConfigId configId;
  string sourceAttributeName;
  string sourceDataType;
  string targetAttributeName;
  string targetDataType;
  MappingTransformation[] transformations;
  string delimiter;     /// For multi-source string concatenation
  int    sortOrder;     /// When multiple sources map to same target
  bool   active;

  Json toJson() const {
    auto tArr = Json.emptyArray;
    foreach (t; transformations) {
      tArr ~= Json.emptyObject
        .set("type", t.type)
        .set("parameter", t.parameter);
    }

    return entityToJson()
      .set("configId", configId.value)
      .set("sourceAttributeName", sourceAttributeName)
      .set("sourceDataType", sourceDataType)
      .set("targetAttributeName", targetAttributeName)
      .set("targetDataType", targetDataType)
      .set("transformations", tArr)
      .set("delimiter", delimiter)
      .set("sortOrder", sortOrder)
      .set("active", active);
  }
}
