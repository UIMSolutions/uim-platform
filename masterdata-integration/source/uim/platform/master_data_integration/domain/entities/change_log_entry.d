/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.entities.change_log_entry;

import uim.platform.master_data_integration.domain.types;

/// A change log entry for tracking master data modifications.
struct ChangeLogEntry {
  mixin TenantEntity!(ChangeLogEntryId);

  MasterDataObjectId objectId;
  DataModelId dataModelId;
  MasterDataCategory category = MasterDataCategory.businessPartner;
  ChangeType changeType = ChangeType.create_;

  // What changed
  string objectType;
  string[] changedFields;
  string[string] oldValues;
  string[string] newValues;

  // Source system
  string sourceSystem;
  string sourceClient;
  string changedBy;

  // Version info
  long fromVersion;
  long toVersion;

  // Delta token for incremental reads
  string deltaToken;

  long timestamp;

  Json toJson() const {
    return entityToJson
      .set("objectId", objectId.value)
      .set("dataModelId", dataModelId.value)
      .set("category", category.to!string)
      .set("changeType", changeType.to!string)
      .set("objectType", objectType)
      .set("changedFields", changedFields.array)
      .set("oldValues", oldValues)
      .set("newValues", newValues)
      .set("sourceSystem", sourceSystem)
      .set("sourceClient", sourceClient)
      .set("changedBy", changedBy)
      .set("fromVersion", fromVersion)
      .set("toVersion", toVersion)
      .set("deltaToken", deltaToken)
      .set("timestamp", timestamp);
  }
}
