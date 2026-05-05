/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.configuration;

// import uim.platform.hana.domain.types;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct Configuration {
  mixin TenantEntity!(ConfigurationId);

  DatabaseInstanceId instanceId;
  string section;
  string key;
  string value;
  string defaultValue;
  ConfigScope scope_;
  ConfigDataType dataType;
  string description;
  bool isReadOnly;
  bool requiresRestart;
  
  Json toJson() const {
    return entityToJson
      .set("instanceId", instanceId.value)
      .set("section", section)
      .set("key", key)
      .set("value", value)
      .set("defaultValue", defaultValue)
      .set("scope", scope_.toString())
      .set("dataType", dataType.toString())
      .set("description", description)
      .set("isReadOnly", isReadOnly)
      .set("requiresRestart", requiresRestart);
  }
}
