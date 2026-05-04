/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.entities.schema;

// import uim.platform.document_ai.domain.types;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct SchemaField {
  string name;
  string label;
  FieldValueType type;
  bool required;
  string description;
  string defaultValue;
  string format;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("label", label)
      .set("type", type.to!string)
      .set("required", required)
      .set("description", description)
      .set("defaultValue", defaultValue)
      .set("format", format);
  }
}

struct LineItemField {
  string name;
  string label;
  FieldValueType type;
  bool required;
  string description;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("label", label)
      .set("type", type.to!string)
      .set("required", required)
      .set("description", description);
  }
}

struct Schema {
  mixin TenantEntity!SchemaId;

  ClientId clientId;
  DocumentTypeId documentTypeId;
  string name;
  string description;
  SchemaStatus status;
  SchemaField[] headerFields;
  LineItemField[] lineItemFields;
  string[] supportedLanguages;
  
  Json toJson() const {
    return entityToJson
      .set("clientId", clientId)
      .set("documentTypeId", documentTypeId)
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string)
      .set("headerFields", headerFields.map!(f => f.toJson()).array)
      .set("lineItemFields", lineItemFields.map!(f => f.toJson()).array)
      .set("supportedLanguages", supportedLanguages);
  }
}
