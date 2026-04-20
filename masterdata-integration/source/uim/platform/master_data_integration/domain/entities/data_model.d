/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.entities.data_model;

import uim.platform.master_data_integration.domain.types;

/// Defines the schema/structure of a master data entity type.
struct DataModel {
  mixin TenantEntity!(DataModelId);

  string name; // e.g. "BusinessPartner", "CostCenter"
  string namespace; // e.g. "sap.odm.businesspartner"
  string version_; // e.g. "2.0.0"
  string description;
  MasterDataCategory category = MasterDataCategory.businessPartner;

  FieldDefinition[] fields;
  string[] keyFields; // Fields that form the primary key
  string[] requiredFields;

  bool isActive;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("namespace", namespace)
      .set("version", version_)
      .set("description", description)
      .set("category", category.to!string)
      .set("fields", fields.map!(f => f.toJson()).array)
      .set("keyFields", keyFields.array)
      .set("requiredFields", requiredFields.array)
      .set("isActive", isActive);
  }
}

/// A field definition within a data model.
struct FieldDefinition {
  string name;
  string displayName;
  FieldType type_ = FieldType.string_;
  bool isRequired;
  bool isKey;
  string defaultValue;
  int maxLength;
  string referenceModel; // For reference fields
  string description;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("displayName", displayName)
      .set("type", type_.to!string)
      .set("isRequired", isRequired)
      .set("isKey", isKey)
      .set("defaultValue", defaultValue)
      .set("maxLength", maxLength)
      .set("referenceModel", referenceModel)
      .set("description", description);
  }
}
