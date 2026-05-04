/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.entities.document_type;

// import uim.platform.document_ai.domain.types;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct DocumentType {
  mixin TenantEntity!DocumentTypeId;

  ClientId clientId;
  string name;
  string description;
  DocumentCategory category;
  SchemaId defaultSchemaId;
  string[] supportedFileTypes;
  
  Json toJson() const {
    return entityToJson
      .set("clientId", clientId)
      .set("name", name)
      .set("description", description)
      .set("category", category.to!string)
      .set("defaultSchemaId", defaultSchemaId)
      .set("supportedFileTypes", supportedFileTypes);
  }
}
