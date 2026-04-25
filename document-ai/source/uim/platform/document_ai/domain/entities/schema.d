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
}

struct LineItemField {
  string name;
  string label;
  FieldValueType type;
  bool required;
  string description;
}

struct Schema {
  SchemaId id;
  TenantId tenantId;
  ClientId clientId;
  DocumentTypeId documentTypeId;
  string name;
  string description;
  SchemaStatus status;
  SchemaField[] headerFields;
  LineItemField[] lineItemFields;
  string[] supportedLanguages;
  long createdAt;
  long updatedAt;
}
