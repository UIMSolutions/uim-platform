/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.entities.master_data_object;

import uim.platform.master_data_integration.domain.types;

/// A master data record — the core entity managed by MDI.
struct MasterDataObject {
  mixin TenantEntity!(MasterDataObjectId);

  DataModelId dataModelId;
  MasterDataCategory category = MasterDataCategory.businessPartner;
  RecordStatus status = RecordStatus.active;

  string objectType; // e.g. "sap.odm.businesspartner.BusinessPartner"
  string displayName;
  string description;

  // Versioning
  VersionId currentVersion;
  long versionNumber;

  // Key fields
  string localId; // ID in the source system
  string globalId; // Globally unique / canonical ID

  // Payload as key-value (simplified; real MDI uses deep structures)
  string[string] attributes;

  // Source system tracking
  string sourceSystem;
  string sourceClient;

  Json toJson() const {
    return entityToJson
      .set("dataModelId", dataModelId.value)
      .set("category", category.to!string)
      .set("status", status.to!string)
      .set("objectType", objectType)
      .set("displayName", displayName)
      .set("description", description)
      .set("currentVersion", currentVersion.value)
      .set("versionNumber", versionNumber)
      .set("localId", localId)
      .set("globalId", globalId)
      .set("attributes", attributes) // Note: this is a simplification
      .set("sourceSystem", sourceSystem)
      .set("sourceClient", sourceClient);
  }
}
