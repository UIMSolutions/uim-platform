/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.entities.template_;

// import uim.platform.document_ai.domain.types;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct TemplateRegion {
  string fieldName;
  int page;
  double x;
  double y;
  double width;
  double height;
}

struct Template {
  TemplateId id;
  TenantId tenantId;
  ClientId clientId;
  SchemaId schemaId;
  DocumentTypeId documentTypeId;
  string name;
  string description;
  TemplateStatus status;
  TemplateRegion[] regions;
  string[] sampleDocumentIds;
  long createdAt;
  long modifiedAt;
}
