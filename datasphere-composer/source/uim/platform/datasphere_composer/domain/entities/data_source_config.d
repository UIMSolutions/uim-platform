/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.entities.data_source_config;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:

/// Per-product configuration: quality rank, timestamp, identifier mappings, attribute mappings, rule overrides.
struct DataSourceConfig {
  mixin TenantEntity!(DataSourceConfigId);

  DataProductId  dataProductId;
  DataProviderId providerId;
  DataQualityRank qualityRank;
  TimestampConfig timestampConfig;
  IdentifierMapping[] identifierMappings;
  bool enabled;
  string[] disabledRuleIds;  /// Unification rules explicitly disabled for this source
  string[string] metadata;

  Json toJson() const {
    auto idMapArr = Json.emptyArray;
    foreach (m; identifierMappings) {
      idMapArr ~= Json.emptyObject
        .set("ruleId", m.ruleId)
        .set("ruleAttributeName", m.ruleAttributeName)
        .set("sourceAttributeName", m.sourceAttributeName)
        .set("transformationType", m.transformationType);
    }

    auto disArr = Json.emptyArray;
    foreach (r; disabledRuleIds) disArr ~= Json(r);

    auto tsJson = Json.emptyObject
      .set("format", timestampConfig.format)
      .set("fieldName", timestampConfig.fieldName)
      .set("customPattern", timestampConfig.customPattern);

    return entityToJson()
      .set("dataProductId", dataProductId.value)
      .set("providerId", providerId.value)
      .set("qualityRank", qualityRank.to!string)
      .set("timestampConfig", tsJson)
      .set("identifierMappings", idMapArr)
      .set("enabled", enabled)
      .set("disabledRuleIds", disArr);
  }
}
