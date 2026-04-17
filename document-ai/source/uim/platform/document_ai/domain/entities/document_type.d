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
  DocumentTypeId id;
  TenantId tenantId;
  ClientId clientId;
  string name;
  string description;
  DocumentCategory category;
  SchemaId defaultSchemaId;
  string[] supportedFileTypes;
  long createdAt;
  long modifiedAt;
}
